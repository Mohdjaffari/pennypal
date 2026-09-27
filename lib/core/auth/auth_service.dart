import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/Auth/LoginScreen.dart';

/// Central Authentication and Session Management Service for PennyPal.
/// Handles Guest Mode, user login states, and automated authentication guards
/// when users attempt to perform protected actions.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> userNameNotifier = ValueNotifier<String>('Guest');

  bool get isLoggedIn => isLoggedInNotifier.value;
  String get userName => userNameNotifier.value;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final name = prefs.getString('userName') ?? (loggedIn ? 'Umair Khan' : 'Guest');

    isLoggedInNotifier.value = loggedIn;
    userNameNotifier.value = loggedIn ? name : 'Guest';
    _initialized = true;
  }

  Future<void> login({required String name, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);
    if (email != null) {
      await prefs.setString('userEmail', email);
    }

    isLoggedInNotifier.value = true;
    userNameNotifier.value = name;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setString('userName', 'Guest');

    isLoggedInNotifier.value = false;
    userNameNotifier.value = 'Guest';
  }

  /// Professional Auth Guard:
  /// Verifies if the user has an active account. If in Guest Mode,
  /// directly navigates to LoginScreen with clear contextual reasoning.
  /// Returns `true` if user successfully authenticated, or `false` if cancelled.
  Future<bool> requireAuth(
    BuildContext context, {
    String? reason,
  }) async {
    if (isLoggedIn) return true;

    final loginResult = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => LoginScreen(
          redirectReason: reason ?? 'Please log in or create an account to perform this action.',
        ),
      ),
    );
    return loginResult == true || isLoggedIn;
  }
}
