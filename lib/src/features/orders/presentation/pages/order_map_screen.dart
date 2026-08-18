import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';

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
  StreamSubscription<Position>? _positionStreamSubscription;
  Order? _selectedOrder; // tracks which stop marker was tapped
  int _selectedStopIndex = 0;

  static const String _googleApiKey = "AIzaSyCZw4DVNyJwP85ZeDG1y_x8DLQ7bF8J0EU";

  @override
  void initState() {
    super.initState();
    _initMapData();
    _initSocket();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    getIt<TrackingSocketService>().disconnect();
    super.dispose();
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _updateUserMarker(position);
        });
      }
    });
  }

  Future<void> _initSocket() async {
    try {
      final ongoingOrder = _getFirstOngoingOrder();
      if (ongoingOrder == null) {
        logger.w("OrderMapScreen: No ongoing order found to track.");
        return;
      }

      final token = await SessionManager.getAuthToken();
      if (token == null || token.isEmpty) {
        logger.e("OrderMapScreen: Auth token is missing.");
        return;
      }

      final uri = Uri.parse(ApiUrl.baseUrl);
      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final wsUrl = '$wsScheme://${uri.authority}/api/v1/ws?token=$token';

      logger.i("OrderMapScreen: Starting tracking for order ${ongoingOrder.uuId} at $wsUrl");
      
      await getIt<TrackingSocketService>().startTracking(
        socketUrl: wsUrl,
        orderId: ongoingOrder.uuId,
      );
    } catch (e) {
      logger.e("OrderMapScreen: Error initializing socket: $e");
    }
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

    // Add a marker for EVERY order stop with valid coordinates
    LatLng? ongoingLocation;
    Order? ongoingOrder = _getFirstOngoingOrder();
    // collect only orders with valid coords for stop numbering
    final validOrders = widget.orders
        .where((o) => o.deliveryLat != 0 || o.deliveryLng != 0)
        .toList();
    for (int i = 0; i < validOrders.length; i++) {
      final order = validOrders[i];
      final isOngoing = ongoingOrder != null && order.id == ongoingOrder.id;
      final stopLocation = LatLng(order.deliveryLat, order.deliveryLng);
      if (isOngoing) ongoingLocation = stopLocation;
      final String mId = order.uuId.isNotEmpty ? order.uuId : "order_${order.id}";
      final int stopNum = i + 1;
      _markers[MarkerId(mId)] = Marker(
        markerId: MarkerId(mId),
        position: stopLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isOngoing ? BitmapDescriptor.hueRed : BitmapDescriptor.hueViolet,
        ),
        // No infoWindow – we show our own custom card overlay
        onTap: () {
          setState(() {
            _selectedOrder = order;
            _selectedStopIndex = stopNum;
          });
        },
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
        title: Text(
          'Delivery Path (${widget.orders.length} Stops)',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.darkOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // ── Map (dismisses card on tap) ─────────────────────────
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 12,
            ),
            markers: Set<Marker>.of(_markers.values),
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (_) {
              // dismiss the card when tapping on empty map area
              if (_selectedOrder != null) {
                setState(() => _selectedOrder = null);
              }
            },
          ),

          // ── Custom stop info card (shown on marker tap) ─────────
          if (_selectedOrder != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      context.pushNamed(
                        AppRoute.bulkOrderDetails.name,
                        extra: _selectedOrder,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Stop number badge
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColor.darkOrange,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$_selectedStopIndex',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Stop details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedOrder!.customerName.isNotEmpty
                                        ? _selectedOrder!.customerName
                                        : 'Stop $_selectedStopIndex',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_selectedOrder!.deliveryAddress.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      _selectedOrder!.deliveryAddress,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // ── Info / Details icon button ──
                            IconButton(
                              tooltip: 'View Order Details',
                              style: IconButton.styleFrom(
                                backgroundColor: AppColor.darkOrange,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                              ),
                              icon: const Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: () {
                                context.pushNamed(
                                  AppRoute.bulkOrderDetails.name,
                                  extra: _selectedOrder,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Loading overlay ─────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(color: AppColor.darkOrange),
              ),
            ),
        ],
      ),
    );
  }
}
