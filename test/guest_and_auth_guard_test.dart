import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pages_app/core/auth/auth_service.dart';
import 'package:pages_app/components/Auth/LoginScreen.dart';
import 'package:pages_app/HomePage.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AuthService.instance.logout();
  });

  testWidgets('Guest mode displays Guest on HomePage and LoginScreen renders redirectReason',
      (WidgetTester tester) async {
    // 1. Verify guest mode state
    expect(AuthService.instance.isLoggedIn, isFalse);
    expect(AuthService.instance.userName, 'Guest');

    // 2. Render LoginScreen with redirectReason (as when redirected by AuthGuard)
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(
          redirectReason: 'Please log in or create an account to view and manage your profile.',
        ),
      ),
    );

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(
      find.text('Please log in or create an account to view and manage your profile.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.lock_person_rounded), findsOneWidget);
  });

  testWidgets('HomePage dynamically responds to AuthService login and logout',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Homepage(),
      ),
    );
    await tester.pump();

    // In Guest mode, greeting should display Guest
    expect(find.text('Hello, Guest 👋'), findsOneWidget);

    // Simulate login
    await AuthService.instance.login(name: 'Sarah Connor');
    await tester.pumpAndSettle();

    // Now greeting should dynamically update to Sarah Connor
    expect(find.text('Hello, Sarah Connor 👋'), findsOneWidget);

    // Logout
    await AuthService.instance.logout();
    await tester.pumpAndSettle();

    expect(find.text('Hello, Guest 👋'), findsOneWidget);
  });
}
