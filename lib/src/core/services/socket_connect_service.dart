import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

class TrackingSocketService {
  WebSocket? _socket;

  final StreamController<Map<String, dynamic>> _messageController =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream =>
      _messageController.stream;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  String? _socketUrl;
  String? _orderId;

  int _sequence = 1;

  bool _manuallyDisconnected = false;
  DateTime? _lastSentTime;

  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  Future<void> startTracking({
    required String socketUrl,
    required String orderId,
  }) async {
    _socketUrl = socketUrl;
    _orderId = orderId;
    _manuallyDisconnected = false;
    _sequence = 1;
    _lastSentTime = null;

    await _connect();
  }

  Future<void> _connect() async {
    try {
      if (isConnected) {
        logger.i("TrackingSocketService: Already connected");
        return;
      }

      logger.i(
        "TrackingSocketService: Connecting to $_socketUrl",
      );

      _socket = await WebSocket.connect(
        _socketUrl!,
      ).timeout(
        const Duration(seconds: 10),
      );

      logger.i(
        "TrackingSocketService: Connected successfully",
      );

      _socket!.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (error) {
          logger.e(
            "TrackingSocketService Error: $error",
          );
          _onDisconnected();
        },
        cancelOnError: true,
      );

      _startLocationUpdates();
      _startPing();
    } catch (e) {
      logger.e("Connection Failed: $e");
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      logger.d("Socket Received: $message");

      final data = jsonDecode(message);

      if (data is Map<String, dynamic>) {
        _messageController.add(data);

        switch (data['type']) {
          case 'location_ack':
            logger.i(
              "Location ACK received. Sequence: ${data['sequence']}",
            );
            break;

          case 'pong':
            logger.d("Pong received");
            break;

          case 'error':
            logger.e(
              "Socket Error: ${data['message']}",
            );
            break;

          default:
            logger.d(
              "Unhandled Socket Event: ${data['type']}",
            );
        }
      }
    } catch (e) {
      logger.e("Message Parse Error: $e");
    }
  }

  Future<void> _startLocationUpdates() async {
    _positionSubscription?.cancel();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.e("TrackingSocketService: Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.e("TrackingSocketService: Location permissions are denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.e("TrackingSocketService: Location permissions permanently denied.");
        return;
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen(
        (Position position) {
          _sendLocation(position);
        },
        onError: (error) {
          logger.e("TrackingSocketService: Position stream error: $error");
        },
      );

      logger.i("TrackingSocketService: Location stream subscription started");

      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      _sendLocation(initialPosition);
    } catch (e) {
      logger.e("TrackingSocketService: Failed to start location updates: $e");
    }
  }

  void _sendLocation(Position position) {
    if (!isConnected || _orderId == null) {
      return;
    }

    final now = DateTime.now();
    if (_lastSentTime != null &&
        now.difference(_lastSentTime!) < const Duration(milliseconds: 2500)) {
      logger.d("TrackingSocketService: Throttling location update. Less than 2.5s elapsed.");
      return;
    }

    try {
      final payload = {
        "type": "location_update",
        "order_id": _orderId,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "accuracy": position.accuracy,
        "heading": position.heading,
        "speed": position.speed,
        "sequence": _sequence++,
        "recorded_at": DateTime.now().toUtc().toIso8601String(),
      };

      _socket?.add(
        jsonEncode(payload),
      );

      _lastSentTime = now;

      logger.d(
        "TrackingSocketService Sent Location: ${jsonEncode(payload)}",
      );
    } catch (e) {
      logger.e(
        "TrackingSocketService: Failed to send location: $e",
      );
    }
  }

  void _startPing() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) {
        if (!isConnected) return;

        sendMessage({
          "type": "ping",
        });
      },
    );
  }

  void sendMessage(dynamic message) {
    if (!isConnected) {
      logger.w("Socket not connected");
      return;
    }

    try {
      final payload =
      (message is Map || message is List)
          ? jsonEncode(message)
          : message;

      _socket?.add(payload);

      logger.d("Socket Sent: $payload");
    } catch (e) {
      logger.e("Send Message Error: $e");
    }
  }

  void _onDisconnected() {
    logger.w("Socket disconnected");

    _socket = null;

    _positionSubscription?.cancel();
    _pingTimer?.cancel();

    if (!_manuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_manuallyDisconnected) {
      return;
    }

    _reconnectTimer?.cancel();

    logger.i(
      "Reconnecting in 5 seconds...",
    );

    _reconnectTimer = Timer(
      const Duration(seconds: 5),
          () async {
        if (!_manuallyDisconnected) {
          await _connect();
        }
      },
    );
  }

  void stopTracking() {
    logger.i("Tracking stopped");

    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void disconnect() {
    _manuallyDisconnected = true;

    _positionSubscription?.cancel();
    _positionSubscription = null;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();

    _socket?.close();

    _socket = null;

    logger.i(
      "TrackingSocketService disconnected",
    );
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}