import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class OrderMapScreen extends StatefulWidget {
  final List<Order> orders;

  const OrderMapScreen({super.key, required this.orders});

  @override
  State<OrderMapScreen> createState() => _OrderMapScreenState();
}

class _OrderMapScreenState extends State<OrderMapScreen> {
  late GoogleMapController _mapController;
  final Map<MarkerId, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  Position? _currentPosition;
  
  static const String _googleApiKey = "AIzaSyCZw4DVNyJwP85ZeDG1y_x8DLQ7bF8J0EU";

  @override
  void initState() {
    super.initState();
    _initMapData();
  }

  Future<void> _initMapData() async {
    _createMarkers(); 
    _currentPosition = await _determinePosition();
    if (_currentPosition != null) {
      _updateUserMarker(_currentPosition!);
    }
    _fetchRoadPath();
    _printDebugInfo();
  }

  void _updateUserMarker(Position pos) {
    if (!mounted) return;
    setState(() {
      _markers[const MarkerId('user_location')] = Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(pos.latitude, pos.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
      );
    });
  }

  Future<void> _printDebugInfo() async {
    debugPrint("=== MAP SCREEN DEBUG INFO ===");
    LatLng? storeLoc = _getStoreLocation();
    debugPrint("STORE LOCATION: ${storeLoc?.latitude}, ${storeLoc?.longitude}");
    
    Order? firstOrder = _getFirstOngoingOrder();
    debugPrint("1ST ORDER LOCATION: ${firstOrder?.deliveryLat}, ${firstOrder?.deliveryLng} (ID: ${firstOrder?.id})");
    debugPrint("DELIVERY BOY LIVE LOCATION: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}");
    debugPrint("==============================");
  }

  LatLng? _getStoreLocation() {
    for (var order in widget.orders) {
      if (order.storeLatitude != null && order.storeLongitude != null && order.storeLatitude != 0 && order.storeLongitude != 0) {
        return LatLng(order.storeLatitude!, order.storeLongitude!);
      }
    }
    return null;
  }

  Order? _getFirstOngoingOrder() {
    for (var order in widget.orders) {
      final String status = order.orderStatus.toUpperCase();
      if (status != 'DELIVERED' && status != 'REJECTED' && order.deliveryLat != 0 && order.deliveryLng != 0) {
        return order;
      }
    }
    return null;
  }

  void _createMarkers() {
    final userMarker = _markers[const MarkerId('user_location')];
    _markers.clear();
    if (userMarker != null) _markers[const MarkerId('user_location')] = userMarker;
    
    _polylines.removeWhere((p) => p.polylineId.value == 'delivery_path_fallback');
    
    LatLng? storeLocation = _getStoreLocation();
    if (storeLocation != null) {
      _markers[const MarkerId('store')] = Marker(
        markerId: const MarkerId('store'),
        position: storeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Store', snippet: 'Pick-up point'),
      );
    }

    Order? ongoingOrder = _getFirstOngoingOrder();
    LatLng? ongoingLocation;
    if (ongoingOrder != null) {
      ongoingLocation = LatLng(ongoingOrder.deliveryLat, ongoingOrder.deliveryLng);
      final String mId = ongoingOrder.uuId.isNotEmpty ? ongoingOrder.uuId : "order_${ongoingOrder.id}";
      _markers[MarkerId(mId)] = Marker(
        markerId: MarkerId(mId),
        position: ongoingLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: ongoingOrder.customerName.isNotEmpty ? ongoingOrder.customerName : 'Customer',
          snippet: ongoingOrder.deliveryAddress,
        ),
      );
    }

    // Comprehensive Fallback Polyline (Dashed)
    if (_polylines.isEmpty) {
      List<LatLng> fallbackPoints = [];
      if (_currentPosition != null) fallbackPoints.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
      if (storeLocation != null) fallbackPoints.add(storeLocation);
      if (ongoingLocation != null) fallbackPoints.add(ongoingLocation);

      if (fallbackPoints.length > 1) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('delivery_path_fallback'),
            points: fallbackPoints,
            color: AppColor.darkOrange.withOpacity(0.5),
            width: 3,
            patterns: [PatternItem.dash(10), PatternItem.gap(10)],
          ),
        );
      }
    }
  }

  Future<void> _fetchRoadPath() async {
    if (widget.orders.isEmpty) return;
    try {
      LatLng? storeLocation = _getStoreLocation();
      Order? ongoingOrder = _getFirstOngoingOrder();
      if (ongoingOrder == null) return;
      
      final destination = "${ongoingOrder.deliveryLat},${ongoingOrder.deliveryLng}";
      String url = "";

      if (_currentPosition != null) {
        // Mode A: Current -> Store -> Order
        final origin = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
        url = "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$_googleApiKey";
        if (storeLocation != null) {
          url += "&waypoints=optimize:true|${storeLocation.latitude},${storeLocation.longitude}";
        }
      } else if (storeLocation != null) {
        // Mode B: Store -> Order (if current location unknown)
        url = "https://maps.googleapis.com/maps/api/directions/json?origin=${storeLocation.latitude},${storeLocation.longitude}&destination=$destination&key=$_googleApiKey";
      } else {
        return;
      }

      final response = await Dio().get(url);
      
      if (response.data['status'] == 'OK') {
        final String encodedPolyline = response.data['routes'][0]['overview_polyline']['points'];
        final List<LatLng> decodedPoints = _decodePolyline(encodedPolyline);
        if (mounted) {
          setState(() {
            _polylines.removeWhere((p) => p.polylineId.value == 'delivery_path_fallback');
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('delivery_path'),
                points: decodedPoints,
                color: Colors.blue.shade700,
                width: 6,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            );
          });
          _fitBounds(_currentPosition);
        }
      } else {
        debugPrint("Directions API error: ${response.data['status']}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Road path error: ${response.data['status']}")),
          );
        }
        // If Mode A failed, try Mode B as fallback
        if (_currentPosition != null && storeLocation != null) {
          _currentPosition = null; // Forces Mode B in next call
          _fetchRoadPath();
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
      if (_currentPosition == null) {
        _currentPosition = await _determinePosition();
      }
      
      if (_currentPosition != null) {
        _updateUserMarker(_currentPosition!);
        _fitBounds(_currentPosition);
      } else if (_markers.isNotEmpty) {
        _fitBounds(null);
      }
    } catch (e) {
      debugPrint("Error setting initial location: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    try {
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 5));
    } catch (e) {
      return null;
    }
  }

  void _fitBounds(Position? userPosition) {
    List<LatLng> points = _markers.values.map((m) => m.position).toList();
    if (userPosition != null) points.add(LatLng(userPosition.latitude, userPosition.longitude));
    
    if (points.isEmpty) return;
    double? minLat, maxLat, minLng, maxLng;
    for (var point in points) {
      if (minLat == null || point.latitude < minLat) minLat = point.latitude;
      if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
      if (minLng == null || point.longitude < minLng) minLng = point.longitude;
      if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
    }
    
    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 70.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Path', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.darkOrange,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 12),
            markers: Set<Marker>.of(_markers.values),
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading) Container(color: Colors.white.withOpacity(0.8), child: const Center(child: CircularProgressIndicator(color: AppColor.darkOrange))),
        ],
      ),
    );
  }
}
