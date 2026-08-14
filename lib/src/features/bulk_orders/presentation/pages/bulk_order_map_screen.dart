import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';

class BulkOrderMapScreen extends StatefulWidget {
  final LatLng storeLocation;
  final List<LatLng> deliveryLocations;

  const BulkOrderMapScreen({
    super.key,
    required this.storeLocation,
    required this.deliveryLocations,
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

  static const String _googleApiKey = "AIzaSyCZw4DVNyJwP85ZeDG1y_x8DLQ7bF8J0EU";

  @override
  void initState() {
    super.initState();
    _setMarkers();
    _getRoutePolyline();
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

  void _setMarkers() {
    final markers = <Marker>{};

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

      markers.add(
        Marker(
          markerId: MarkerId('order_$i'),
          position: widget.deliveryLocations[i],
          infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
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
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
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
          ),
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
