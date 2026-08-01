import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../utils/logger.dart';

class SocketConnectService {
  WebSocket? _socket;
  final StreamController<dynamic> _messageController = StreamController<dynamic>.broadcast();

  /// Stream of messages received from the socket
  Stream<dynamic> get messageStream => _messageController.stream;

  /// Returns true if the socket is currently connected
  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  /// Connects to the WebSocket at the given [url]
  Future<void> connect(String url) async {
    if (isConnected) {
      logger.i("SocketConnectService: Already connected");
      return;
    }

    try {
      logger.i("SocketConnectService: Connecting to $url");
      _socket = await WebSocket.connect(url).timeout(const Duration(seconds: 10));
      
      _socket!.listen(
        (data) {
          logger.d("SocketConnectService: Received: $data");
          _messageController.add(data);
        },
        onError: (error) {
          logger.e("SocketConnectService: Error: $error");
          _handleDisconnection();
        },
        onDone: () {
          logger.i("SocketConnectService: Connection closed by server");
          _handleDisconnection();
        },
        cancelOnError: true,
      );

      logger.i("SocketConnectService: Connected successfully");
    } catch (e) {
      logger.e("SocketConnectService: Connection failed: $e");
      rethrow;
    }
  }

  void _handleDisconnection() {
    _socket?.close();
    _socket = null;
  }

  /// Sends a [message] through the socket. 
  /// If the message is a Map or List, it will be JSON encoded.
  void sendMessage(dynamic message) {
    if (isConnected) {
      final data = (message is Map || message is List) ? jsonEncode(message) : message;
      _socket!.add(data);
      logger.d("SocketConnectService: Sent: $data");
    } else {
      logger.w("SocketConnectService: Not connected. Cannot send message.");
    }
  }

  /// Disconnects from the current WebSocket
  void disconnect() {
    _socket?.close();
    _socket = null;
    logger.i("SocketConnectService: Disconnected");
  }

  /// Disposes the service and closes the message stream
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
