import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity monitor that broadcasts online/offline state changes.
class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = _hasConnection(results);
    } catch (_) {
      _isOnline = true; // Optimistic fallback
    }

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = _hasConnection(results);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(online);
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
