import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class MapScreen extends StatefulWidget {
  final List<Order> orders;

  const MapScreen({super.key, required this.orders});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Map<MarkerId, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  
  // Using the API key from AndroidManifest
  static const String _googleApiKey = "AIzaSyCZw4DVNyJwP85ZeDG1y_x8DLQ7bF8J0EU";

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _fetchRoadPath();
  }

  void _createMarkers() {
    _markers.clear();
    _polylines.clear();

    List<LatLng> directPoints = [];

    if (widget.orders.isNotEmpty) {
      final firstOrder = widget.orders.first;
      if (firstOrder.storeLatitude != null && firstOrder.storeLongitude != null) {
        final storeLatLng = LatLng(firstOrder.storeLatitude!, firstOrder.storeLongitude!);
        const markerId = MarkerId('store');
        _markers[markerId] = Marker(
          markerId: markerId,
          position: storeLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Store Location'),
        );
        directPoints.add(storeLatLng);
      }
    }

    for (var order in widget.orders) {
      if (order.deliveryLat != 0 && order.deliveryLng != 0) {
        final markerId = MarkerId(order.id.toString());
        final latLng = LatLng(order.deliveryLat, order.deliveryLng);
        _markers[markerId] = Marker(
          markerId: markerId,
          position: latLng,
          infoWindow: InfoWindow(
            title: order.customerName,
            snippet: order.deliveryAddress,
          ),
        );
        directPoints.add(latLng);
      }
    }

    // Show straight line initially while we fetch the road path
    if (directPoints.length > 1) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('delivery_path'),
          points: directPoints,
          color: AppColor.darkOrange.withOpacity(0.5),
          width: 3,
          patterns: [PatternItem.dash(10), PatternItem.gap(10)],
        ),
      );
    }
  }

  Future<void> _fetchRoadPath() async {
    if (widget.orders.isEmpty) return;

    try {
      final firstOrder = widget.orders.first;
      if (firstOrder.storeLatitude == null || firstOrder.storeLongitude == null) return;

      final origin = "${firstOrder.storeLatitude},${firstOrder.storeLongitude}";
      final destination = "${widget.orders.last.deliveryLat},${widget.orders.last.deliveryLng}";
      
      String waypoints = "";
      if (widget.orders.length > 1) {
        waypoints = "waypoints=";
        for (int i = 0; i < widget.orders.length - 1; i++) {
          waypoints += "${widget.orders[i].deliveryLat},${widget.orders[i].deliveryLng}|";
        }
      }

      final url = "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=$origin&destination=$destination&$waypoints&key=$_googleApiKey";

      final response = await Dio().get(url);
      
      if (response.data['status'] == 'OK') {
        final String encodedPolyline = response.data['routes'][0]['overview_polyline']['points'];
        final List<LatLng> decodedPoints = _decodePolyline(encodedPolyline);

        if (mounted) {
          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('delivery_path'),
                points: decodedPoints,
                color: AppColor.darkOrange,
                width: 5,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            );
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching road path: $e");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    try {
      Position? position = await _determinePosition();
      
      if (_markers.isNotEmpty) {
        // Prioritize showing all markers (Store + Orders)
        _fitBounds(position);
      } else if (position != null) {
        final userLatLng = LatLng(position.latitude, position.longitude);
        _mapController.moveCamera(
          CameraUpdate.newLatLngZoom(userLatLng, 15.0),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Using bestForNavigation to get the tightest possible accuracy circle
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 10),
    );
  }

  void _fitBounds(Position? userPosition) {
    double? minLat, maxLat, minLng, maxLng;

    List<LatLng> points = _markers.values.map((m) => m.position).toList();
    if (userPosition != null) {
      points.add(LatLng(userPosition.latitude, userPosition.longitude));
    }

    for (var point in points) {
      if (minLat == null || point.latitude < minLat) minLat = point.latitude;
      if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
      if (minLng == null || point.longitude < minLng) minLng = point.longitude;
      if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
    }

    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
      if (minLat == maxLat && minLng == maxLng) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 14.0),
        );
      } else {
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            70.0, // Increased padding
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Path',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.darkOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _markers.isNotEmpty 
                  ? _markers.values.first.position 
                  : const LatLng(20.5937, 78.9629),
              zoom: 12,
            ),
            markers: Set<Marker>.of(_markers.values),
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColor.darkOrange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
