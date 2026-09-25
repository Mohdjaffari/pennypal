import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home/home_screen.dart';
import 'components/onboardscreens.dart';

/// Legacy entry point wrapper for the Home screen,
/// maintaining backward compatibility with existing routing.
class Homepage extends StatelessWidget {
  const Homepage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotFirstTime', false);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreens(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      userName: 'Mohd Jaffari',
      onLogout: () => _handleLogout(context),
    );
  }
}