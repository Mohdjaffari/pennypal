// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'core/auth/auth_service.dart';
import 'screens/home/home_screen.dart';
import 'components/Auth/LoginScreen.dart';

/// Legacy entry point wrapper for the Home screen,
/// maintaining backward compatibility with existing routing.
class Homepage extends StatelessWidget {
  const Homepage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.instance.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AuthService.instance.userNameNotifier,
      builder: (context, userName, _) {
        return HomeScreen(
          userName: userName,
          onLogout: () => _handleLogout(context),
        );
      },
    );
  }
}