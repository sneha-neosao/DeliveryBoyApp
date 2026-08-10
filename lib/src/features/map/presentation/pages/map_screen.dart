import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_boy_app/src/remote/models/order_model/order_list_response.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends StatefulWidget {
  final List<Order> orders;

  const MapScreen({super.key, required this.orders});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Map<MarkerId, Marker> _markers = {};

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
    if (_markers.isNotEmpty) {
      _fitBounds();
    }
  }

  void _fitBounds() {
    double? minLat, maxLat, minLng, maxLng;

    for (var marker in _markers.values) {
      if (minLat == null || marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (maxLat == null || marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (minLng == null || marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (maxLng == null || marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }

    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
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
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _markers.isNotEmpty 
              ? _markers.values.first.position 
              : const LatLng(0, 0),
          zoom: 12,
        ),
        markers: Set<Marker>.of(_markers.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
