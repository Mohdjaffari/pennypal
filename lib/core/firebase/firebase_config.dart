import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Safe Firebase initialization manager.
/// When Firebase is configured with real credentials (e.g. via FlutterFire CLI or
/// google-services.json / GoogleService-Info.plist), it enables cloud Firestore sync.
/// Otherwise, it gracefully marks Firebase as offline so PennyPal operates with 100%
/// fidelity on local SQLite database storage without any crashes or connection errors.
class FirebaseConfig {
  FirebaseConfig._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        debugPrint('[FirebaseConfig] Existing Firebase app detected.');
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      debugPrint('[FirebaseConfig] Firebase successfully initialized with current platform options.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('[FirebaseConfig] Firebase fallback offline mode ($e).');
    }
  }
}
