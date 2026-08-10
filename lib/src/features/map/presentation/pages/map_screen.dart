import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final List<Order> orders;

  const MapScreen({super.key, required this.orders});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Map<MarkerId, Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    for (var order in widget.orders) {
      if (order.deliveryLat != 0 && order.deliveryLng != 0) {
        final markerId = MarkerId(order.id.toString());
        final marker = Marker(
          markerId: markerId,
          position: LatLng(order.deliveryLat, order.deliveryLng),
          infoWindow: InfoWindow(
            title: order.customerName,
            snippet: order.deliveryAddress,
          ),
        );
        _markers[markerId] = marker;
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    try {
      // Get position with best possible accuracy to shrink the accuracy circle
      Position? position = await _determinePosition();
      
      if (position != null) {
        final userLatLng = LatLng(position.latitude, position.longitude);
        
        // Use moveCamera for instant focus on your location
        _mapController.moveCamera(
          CameraUpdate.newLatLngZoom(userLatLng, 19.0),
        );
      } else if (_markers.isNotEmpty) {
        _fitBounds(null);
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
            50.0,
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
          'Orders Map',
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
                  : const LatLng(20.5937, 78.9629), // Default to center of India instead of 0,0
              zoom: 12,
            ),
            markers: Set<Marker>.of(_markers.values),
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
