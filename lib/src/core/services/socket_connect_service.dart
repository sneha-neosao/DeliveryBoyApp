import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../configs/injector/injector.dart';

class TrackingSocketService {
  IO.Socket? _socket;

  // ===========================================================================
  // STREAMS
  // ===========================================================================

  final StreamController<Map<String, dynamic>> _messageController =
  StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<bool> _connectionController =
  StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messageStream =>
      _messageController.stream;

  Stream<bool> get connectionStream => _connectionController.stream;

  // ===========================================================================
  // GPS
  // ===========================================================================

  StreamSubscription<Position>? _positionSubscription;

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================

  String? _socketUrl;
  String? _jwtToken;

  int? _deliveryId;

  List<String> _activeOrderIds = [];

  // ===========================================================================
  // STATE
  // ===========================================================================

  bool _manuallyDisconnected = false;
  bool _trackingStarted = false;
  bool _disposed = false;

  DateTime? _lastLocationSentAt;

  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  static const Duration locationInterval = Duration(seconds: 3);

  static const Duration connectionTimeout = Duration(seconds: 10);

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  bool get isConnected => _socket?.connected == true;

  bool get isTracking => _trackingStarted;

  List<String> get activeOrderIds =>
      List.unmodifiable(_activeOrderIds);

  // ===========================================================================
  // START SOCKET
  // ===========================================================================

  Future<void> startTracking({
    required String socketUrl,
    required String jwtToken,
  }) async {
    if (_disposed) {
      logger.w(
        'TrackingSocketService: Service already disposed',
      );
      return;
    }

    _socketUrl = socketUrl;
    _jwtToken = jwtToken;

    _manuallyDisconnected = false;

    logger.i(
      'TrackingSocketService: Starting Socket.IO tracking',
    );

    await _connect();
  }

  // ===========================================================================
  // CONNECT
  // ===========================================================================

  Future<void> _connect() async {
    if (_disposed || _manuallyDisconnected) {
      return;
    }

    if (_socketUrl == null || _jwtToken == null) {
      logger.e(
        'TrackingSocketService: Socket URL or JWT token is missing',
      );
      return;
    }

    if (isConnected) {
      logger.i(
        'TrackingSocketService: Already connected',
      );
      return;
    }

    try {
      // Destroy old socket before creating a new one.
      _socket?.dispose();
      _socket = null;

      logger.i(
        'TrackingSocketService: Connecting to $_socketUrl',
      );

      final options = IO.OptionBuilder()
      // Flutter/Dart VM
          .setTransports(['websocket'])

      // We manually call connect().
          .disableAutoConnect()

      // Socket.IO automatic reconnect.
          .enableReconnection()

      // Keep retrying while the delivery boy is on duty.
          .setReconnectionAttempts(double.infinity)

      // Start reconnecting after ~1 second.
          .setReconnectionDelay(1000)

      // Maximum reconnect delay = 5 seconds.
          .setReconnectionDelayMax(5000)

      // Connection timeout.
          .setTimeout(connectionTimeout.inMilliseconds)

      // Documentation recommends JWT through query.
          .setQuery({
        'token': _jwtToken!,
      })

      // Force a fresh Socket.IO connection.
          .enableForceNew()

          .build();

      _socket = IO.io(
        _socketUrl!,
        options,
      );

      _registerSocketListeners();

      _socket!.connect();
    } catch (e, stackTrace) {
      logger.e(
        'TrackingSocketService: Connection exception',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ===========================================================================
  // SOCKET LISTENERS
  // ===========================================================================

  void _registerSocketListeners() {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    // -------------------------------------------------------------------------
    // CONNECTED
    // -------------------------------------------------------------------------

    socket.onConnect((_) {
      logger.i(
        'TrackingSocketService: Socket.IO connected',
      );

      logger.i(
        'Socket ID: ${socket.id}',
      );

      _connectionController.add(true);

      _sendAcceptDelivery();

      // If tracking was already active before connection dropped,
      // restart GPS updates.
      if (_activeOrderIds.isNotEmpty && !_trackingStarted) {
        _startLocationUpdates();
      }
    });

    // -------------------------------------------------------------------------
    // CONNECT ERROR
    // -------------------------------------------------------------------------

    socket.onConnectError((error) {
      logger.e(
        'TrackingSocketService: Socket connection error: $error',
      );

      _connectionController.add(false);
    });

    // -------------------------------------------------------------------------
    // DISCONNECTED
    // -------------------------------------------------------------------------

    socket.onDisconnect((reason) {
      logger.w(
        'TrackingSocketService: Socket disconnected: $reason',
      );

      _connectionController.add(false);

      // IMPORTANT:
      // Do not stop GPS permanently here.
      //
      // Socket.IO will automatically reconnect.
      //
      // GPS tracking can continue and _sendLocation() will simply
      // skip sending while socket is disconnected.
    });

    // -------------------------------------------------------------------------
    // ERROR
    // -------------------------------------------------------------------------

    socket.onError((error) {
      logger.e(
        'TrackingSocketService: Socket error: $error',
      );
    });

    // -------------------------------------------------------------------------
    // RECONNECT
    // -------------------------------------------------------------------------

    socket.onReconnect((attempt) {
      logger.i(
        'TrackingSocketService: Reconnected. Attempt: $attempt',
      );

      _connectionController.add(true);
    });

    // -------------------------------------------------------------------------
    // RECONNECT ATTEMPT
    // -------------------------------------------------------------------------

    socket.onReconnectAttempt((attempt) {
      logger.i(
        'TrackingSocketService: Reconnect attempt: $attempt',
      );
    });

    // -------------------------------------------------------------------------
    // RECONNECT ERROR
    // -------------------------------------------------------------------------

    socket.onReconnectError((error) {
      logger.e(
        'TrackingSocketService: Reconnect error: $error',
      );
    });

    // -------------------------------------------------------------------------
    // RECONNECT FAILED
    // -------------------------------------------------------------------------

    socket.onReconnectFailed((_) {
      logger.e(
        'TrackingSocketService: Reconnection failed',
      );

      _connectionController.add(false);
    });

    // -------------------------------------------------------------------------
    // SERVER EVENTS
    // -------------------------------------------------------------------------

    socket.on(
      'order:assigned',
      _handleOrderAssigned,
    );

    socket.on(
      'order:completed',
      _handleOrderCompleted,
    );

    socket.on(
      'location:ack',
      _handleLocationAck,
    );

    socket.on(
      'error',
      _handleServerError,
    );
  }

  // ===========================================================================
  // DELIVERY ACCEPTED
  // ===========================================================================

  /// Call this AFTER the delivery boy accepts an assignment.
  ///
  /// Single:
  /// orderIds = ['ORD-1001']
  ///
  /// Bulk:
  /// orderIds = ['ORD-1001', 'ORD-1002', 'ORD-1003']
  void acceptDelivery({
    required int deliveryId,
    required List<String> orderIds,
  }) {
    if (orderIds.isEmpty) {
      logger.w(
        'TrackingSocketService: No order IDs supplied.',
      );
      return;
    }

    _deliveryId = deliveryId;
    _activeOrderIds = List<String>.from(orderIds);

    // Start GPS after assignment is accepted.
    _startLocationUpdates();

    if (isConnected) {
      _sendAcceptDelivery();
    } else {
      logger.i(
        'TrackingSocketService: Socket not connected yet. Will send delivery:accepted on connect.',
      );
    }
  }

  void _sendAcceptDelivery() {
    if (_deliveryId == null || _activeOrderIds.isEmpty) {
      return;
    }

    final Map<String, dynamic> payload = {
      'delivery_id': _deliveryId,
      'order_ids': _activeOrderIds,
    };

    logger.i(
      'TrackingSocketService: Sending delivery:accepted',
    );

    logger.d(
      'delivery:accepted payload: $payload',
    );

    _socket!.emit(
      'delivery:accepted',
      payload,
    );
  }

  // ===========================================================================
  // START LOCATION TRACKING
  // ===========================================================================

  Future<void> _startLocationUpdates() async {
    if (_trackingStarted) {
      logger.i(
        'TrackingSocketService: Location tracking already running',
      );
      return;
    }

    if (_activeOrderIds.isEmpty) {
      logger.w(
        'TrackingSocketService: No active orders. GPS not started.',
      );
      return;
    }

    try {
      // -----------------------------------------------------------------------
      // LOCATION SERVICE
      // -----------------------------------------------------------------------

      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        logger.e(
          'TrackingSocketService: Location services are disabled.',
        );
        return;
      }

      // -----------------------------------------------------------------------
      // PERMISSION
      // -----------------------------------------------------------------------

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          logger.e(
            'TrackingSocketService: Location permission denied.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.e(
          'TrackingSocketService: Location permission permanently denied.',
        );
        return;
      }

      // -----------------------------------------------------------------------
      // LOCATION STREAM
      // -----------------------------------------------------------------------

      await _positionSubscription?.cancel();

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 1,
            ),
          ).listen(
                (Position position) {
              _sendLocation(position);
            },
            onError: (error) {
              logger.e(
                'TrackingSocketService: GPS stream error: $error',
              );
            },
          );

      _trackingStarted = true;

      logger.i(
        'TrackingSocketService: GPS tracking started',
      );

      // -----------------------------------------------------------------------
      // SEND INITIAL LOCATION
      // -----------------------------------------------------------------------

      try {
        final currentPosition =
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        );

        _sendLocation(
          currentPosition,
          force: true,
        );
      } catch (e) {
        logger.e(
          'TrackingSocketService: Failed to get initial location: $e',
        );
      }
    } catch (e, stackTrace) {
      logger.e(
        'TrackingSocketService: Failed to start GPS',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ===========================================================================
  // SEND LOCATION
  // ===========================================================================

  void _sendLocation(
      Position position, {
        bool force = false,
      }) {
    if (!isConnected) {
      logger.w(
        'TrackingSocketService: Socket disconnected. GPS update skipped.',
      );
      return;
    }

    if (_activeOrderIds.isEmpty) {
      logger.w(
        'TrackingSocketService: No active orders. GPS update skipped.',
      );
      return;
    }

    // -------------------------------------------------------------------------
    // THROTTLE
    // -------------------------------------------------------------------------

    final now = DateTime.now();

    if (!force &&
        _lastLocationSentAt != null &&
        now.difference(_lastLocationSentAt!) <
            locationInterval) {
      return;
    }

    // -------------------------------------------------------------------------
    // DOCUMENTATION PAYLOAD
    // -------------------------------------------------------------------------

    final payload = {
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': DateTime.now()
          .toUtc()
          .toIso8601String(),
    };

    try {
      // IMPORTANT:
      // No order_id here.
      //
      // Server automatically knows which active orders belong
      // to this delivery boy.

      _socket!.emit(
        'location:update',
        payload,
      );

      _lastLocationSentAt = now;

      logger.d(
        'TrackingSocketService: location:update sent',
      );

      logger.d(
        'Location: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      logger.e(
        'TrackingSocketService: Failed to send location: $e',
      );
    }
  }

  // ===========================================================================
  // COMPLETE ONE ORDER
  // ===========================================================================

  /// Call this when the delivery boy marks ONE order as delivered.
  ///
  /// For bulk delivery, DO NOT disconnect the socket here.
  void completeOrder(String orderId) {
    if (!isConnected) {
      logger.w(
        'TrackingSocketService: Cannot complete order. Socket disconnected.',
      );
      return;
    }

    if (!_activeOrderIds.contains(orderId)) {
      logger.w(
        'TrackingSocketService: Order $orderId is not in active orders.',
      );
    }

    final payload = {
      'order_id': orderId,
    };

    logger.i(
      'TrackingSocketService: Sending order:delivered for $orderId',
    );

    _socket!.emit(
      'order:delivered',
      payload,
    );

    // Remove this order locally.
    _activeOrderIds.remove(orderId);

    // -------------------------------------------------------------------------
    // IMPORTANT FOR BULK
    // -------------------------------------------------------------------------

    if (_activeOrderIds.isNotEmpty) {
      logger.i(
        'TrackingSocketService: Remaining active orders: '
            '${_activeOrderIds.length}',
      );

      // Keep socket + GPS alive.
      return;
    }

    // No orders left.
    logger.i(
      'TrackingSocketService: All active orders completed.',
    );

    stopTracking();
  }

  // ===========================================================================
  // SERVER: ORDER ASSIGNED
  // ===========================================================================

  void _handleOrderAssigned(dynamic data) {
    logger.i(
      'TrackingSocketService: order:assigned received: $data',
    );

    _addMessage(
      'order:assigned',
      data,
    );
  }

  // ===========================================================================
  // SERVER: ORDER COMPLETED
  // ===========================================================================

  void _handleOrderCompleted(dynamic data) {
    logger.i(
      'TrackingSocketService: order:completed received: $data',
    );

    _addMessage(
      'order:completed',
      data,
    );

    if (data is Map) {
      final orderId = data['order_id']?.toString();

      if (orderId != null) {
        _activeOrderIds.remove(orderId);
      }
    }

    if (_activeOrderIds.isEmpty) {
      stopTracking();
    }
  }

  // ===========================================================================
  // SERVER: LOCATION ACK
  // ===========================================================================

  void _handleLocationAck(dynamic data) {
    logger.d(
      'TrackingSocketService: location ACK: $data',
    );

    _addMessage(
      'location:ack',
      data,
    );
  }

  // ===========================================================================
  // SERVER ERROR
  // ===========================================================================

  void _handleServerError(dynamic data) {
    logger.e(
      'TrackingSocketService: Server error: $data',
    );

    _addMessage(
      'error',
      data,
    );
  }

  // ===========================================================================
  // GENERIC MESSAGE
  // ===========================================================================

  void _addMessage(
      String event,
      dynamic data,
      ) {
    if (_messageController.isClosed) {
      return;
    }

    final Map<String, dynamic> message;

    if (data is Map) {
      message = {
        'event': event,
        ...Map<String, dynamic>.from(data),
      };
    } else {
      message = {
        'event': event,
        'data': data,
      };
    }

    _messageController.add(message);
  }

  // ===========================================================================
  // SEND GENERIC SOCKET EVENT
  // ===========================================================================

  void sendMessage(
      String event, [
        dynamic data,
      ]) {
    if (!isConnected) {
      logger.w(
        'TrackingSocketService: Socket not connected',
      );
      return;
    }

    try {
      if (data == null) {
        _socket!.emit(event);
      } else {
        _socket!.emit(
          event,
          data,
        );
      }

      logger.d(
        'TrackingSocketService: Event sent: $event',
      );
    } catch (e) {
      logger.e(
        'TrackingSocketService: Failed to send event $event: $e',
      );
    }
  }

  // ===========================================================================
  // STOP GPS ONLY
  // ===========================================================================

  void stopTracking() {
    logger.i(
      'TrackingSocketService: Stopping GPS tracking',
    );

    _positionSubscription?.cancel();
    _positionSubscription = null;

    _trackingStarted = false;
    _lastLocationSentAt = null;
  }

  // ===========================================================================
  // CLEAR CURRENT ORDERS
  // ===========================================================================

  void clearActiveOrders() {
    logger.i(
      'TrackingSocketService: Clearing active orders',
    );

    _activeOrderIds.clear();

    stopTracking();
  }

  // ===========================================================================
  // DISCONNECT EVERYTHING
  // ===========================================================================

  void disconnect() {
    logger.i(
      'TrackingSocketService: Manual disconnect',
    );

    _manuallyDisconnected = true;

    stopTracking();

    _activeOrderIds.clear();

    _deliveryId = null;

    _socket?.disconnect();
    _socket?.dispose();

    _socket = null;

    _connectionController.add(false);
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;

    logger.i(
      'TrackingSocketService: Disposing service',
    );

    disconnect();

    _messageController.close();
    _connectionController.close();
  }
}