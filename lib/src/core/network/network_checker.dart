import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import '../errors/failures.dart';

typedef EitherNetwork<T> = Future<Either<Failure, T>> Function();

/// utility class to check and monitor the network connectivity.
class NetworkInfo {
  bool _isConnected = true;

  // 👇 Restore this method
  Future<Either<Failure, T>> check<T>({
    required EitherNetwork<T> connected,
    required EitherNetwork<T> notConnected,
  }) async {
    final isConnected = await checkIsConnected;
    if (isConnected) {
      return connected();
    } else {
      return notConnected();
    }
  }

  Future<bool> get checkIsConnected async {
    final result = await Connectivity().checkConnectivity();

    // If completely offline, don't retry
    if (result == ConnectivityResult.none) return false;

    // First attempt
    bool isReachable = await _pingServer();
    if (isReachable) return true;

    // Retry once after a short delay
    await Future.delayed(const Duration(seconds: 2));
    return await _pingServer();
  }

  set setIsConnected(bool val) => _isConnected = val;
  bool get getIsConnected => _isConnected;

  Future<bool> _pingServer() async {
    try {
      final response = await http
          .get(Uri.parse('https://backend.inorotech.in'))
          .timeout(const Duration(seconds: 3));
      print("ping : $response");
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
