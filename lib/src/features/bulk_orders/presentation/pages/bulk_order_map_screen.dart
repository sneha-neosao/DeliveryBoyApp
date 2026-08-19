import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/food_order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';

class BulkOrderMapScreen extends StatefulWidget {
  final LatLng storeLocation;
  final List<LatLng> deliveryLocations;
  final List<Order> orders;

  const BulkOrderMapScreen({
    super.key,
    required this.storeLocation,
    required this.deliveryLocations,
    this.orders = const [],
  });

  @override
  State<BulkOrderMapScreen> createState() => _BulkOrderMapScreenState();
}

class _BulkOrderMapScreenState extends State<BulkOrderMapScreen> {
  GoogleMapController? _mapController;
  bool _mapReady = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  Order? _selectedOrder;   // tracks which stop marker was tapped
  int _selectedStopIndex = 0;
  BitmapDescriptor? _userMarkerIcon;

  static const String _googleApiKey = "AIzaSyCZw4DVNyJwP85ZeDG1y_x8DLQ7bF8J0EU";

  @override
  void initState() {
    super.initState();
    _initMapData();
    debugPrint(
      "Delivery Count: ${widget.deliveryLocations.length}",
    );

    for (int i = 0; i < widget.deliveryLocations.length; i++) {
      debugPrint(
        "Marker ${i + 1}: "
            "${widget.deliveryLocations[i].latitude}, "
            "${widget.deliveryLocations[i].longitude}",
      );
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<BitmapDescriptor> _loadMarkerIcon() async {
    final byteData = await rootBundle.load('assets/images/map_marker.png');
    final bytes = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 50);
    final frame = await codec.getNextFrame();
    final resizedBytes = (await frame.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    return BitmapDescriptor.bytes(resizedBytes);
  }

  Future<void> _initMapData() async {
    try {
      _userMarkerIcon = await _loadMarkerIcon();
    } catch (e) {
      debugPrint('Failed to load map_marker.png: $e');
    }
    _setMarkers();
    _currentPosition = await _determinePosition();
    if (_currentPosition != null) {
      _updateUserMarker(_currentPosition!);
    }
    _getRoutePolyline();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        _updateUserMarker(position);
      }
    });
  }

  void _updateUserMarker(Position pos) {
    if (!mounted) return;
    setState(() {
      _currentPosition = pos;
      final userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(pos.latitude, pos.longitude),
        icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
        anchor: const Offset(0.5, 0.5),
      );
      _markers.removeWhere((m) => m.markerId == const MarkerId('user_location'));
      _markers.add(userMarker);
    });
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
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 5)),
      );
    } catch (e) {
      return null;
    }
  }

  void _setMarkers() {
    final markers = <Marker>{};

    // Preserve user marker if present
    final userMarker = _markers.firstWhere(
      (m) => m.markerId == const MarkerId('user_location'),
      orElse: () => const Marker(markerId: MarkerId('none')),
    );
    if (userMarker.markerId.value != 'none') {
      markers.add(userMarker);
    } else if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    // Store marker (orange)
    markers.add(
      Marker(
        markerId: const MarkerId('store'),
        position: widget.storeLocation,
        infoWindow: const InfoWindow(title: 'Store', snippet: 'Pick-up point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    // Delivery markers — numbered, colour-coded by sequence
    for (int i = 0; i < widget.deliveryLocations.length; i++) {
      double hue;
      if (widget.deliveryLocations.length == 1 || i == 0) {
        hue = BitmapDescriptor.hueRed;   // first stop
      } else if (i == widget.deliveryLocations.length - 1) {
        hue = BitmapDescriptor.hueGreen; // last stop
      } else {
        hue = BitmapDescriptor.hueBlue;  // intermediate stops
      }

      final int stopNum = i + 1;
      // Match order by index if available
      final Order? matchedOrder = (i < widget.orders.length) ? widget.orders[i] : null;

      markers.add(
        Marker(
          markerId: MarkerId('order_$i'),
          position: widget.deliveryLocations[i],
          // No infoWindow — we show our own custom card overlay
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          onTap: () {
            setState(() {
              _selectedOrder = matchedOrder;
              _selectedStopIndex = stopNum;
            });
          },
        ),
      );
    }

    if (mounted) setState(() => _markers = markers);
  }

  /// Draws the road-following path:
  /// Store → Stop 1 → Stop 2 → ... → Last Stop
  Future<void> _getRoutePolyline() async {
    if (widget.deliveryLocations.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final origin =
        '${widget.storeLocation.latitude},${widget.storeLocation.longitude}';
    final destination =
        '${widget.deliveryLocations.last.latitude},${widget.deliveryLocations.last.longitude}';

    // Waypoints: all stops EXCEPT the last, in original sequence (no optimize)
    final waypoints = widget.deliveryLocations
        .sublist(0, widget.deliveryLocations.length - 1)
        .map((loc) => '${loc.latitude},${loc.longitude}')
        .join('|');

    String url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin'
        '&destination=$destination'
        '&key=$_googleApiKey';
    if (waypoints.isNotEmpty) {
      url += '&waypoints=$waypoints';
    }

    debugPrint('=== BULK MAP PATH ===');
    debugPrint('Origin      : $origin  (Store)');
    widget.deliveryLocations.asMap().forEach((i, loc) {
      debugPrint('Stop ${i + 1}       : ${loc.latitude},${loc.longitude}');
    });
    debugPrint('====================');

    try {
      final response = await Dio().get(url);

      if (response.data['status'] == 'OK') {
        final String encoded =
            response.data['routes'][0]['overview_polyline']['points'];
        final List<LatLng> points = _decodePolyline(encoded);

        if (mounted) {
          setState(() {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('delivery_route'),
                color: Colors.blue.shade700,
                width: 6,
                points: points,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
            _isLoading = false;
          });
          _fitBounds();
        }
      } else {
        debugPrint('Directions API error: ${response.data['status']}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'DEL_ACCEPTED':
        return 'DELIVERY ACCEPTED';
      case 'READY_FOR_PICKUP':
        return 'READY FOR PICK UP';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  void _fitBounds() {
    if (!_mapReady || _markers.isEmpty) return;

    final allPoints = [
      widget.storeLocation,
      ...widget.deliveryLocations,
      if (_currentPosition != null)
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
    ];

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (final p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        70.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery Path (${widget.deliveryLocations.length} Stop${widget.deliveryLocations.length == 1 ? '' : 's'})',
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
          // ── Map (tap dismisses card) ──────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.storeLocation,
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapReady = true;
              _fitBounds();
              if (mounted) setState(() => _isLoading = false);
            },
            onTap: (_) {
              if (_selectedOrder != null || _selectedStopIndex != 0) {
                setState(() {
                  _selectedOrder = null;
                  _selectedStopIndex = 0;
                });
              }
            },
          ),

          // ── Custom stop info card (shown on marker tap) ─────────
          if (_selectedStopIndex > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: _selectedOrder != null
                        ? () {
                            context.pushNamed(
                              AppRoute.bulkOrderDetails.name,
                              extra: _selectedOrder,
                            );
                          }
                        : null,
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
                              decoration: const BoxDecoration(
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
                                    _selectedOrder != null && _selectedOrder!.customerName.isNotEmpty
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
                                  if (_selectedOrder != null) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      _formatStatus(_selectedOrder!.orderStatus),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkOrange,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (_selectedOrder != null && _selectedOrder!.deliveryAddress.isNotEmpty) ...
                                    [
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
                                  if (_selectedOrder == null)
                                    Text(
                                      'Stop $_selectedStopIndex',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
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
                              onPressed: _selectedOrder != null
                                  ? () {
                                      context.pushNamed(
                                        AppRoute.bulkOrderDetails.name,
                                        extra: _selectedOrder,
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Loading overlay ──────────────────────────────────
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
