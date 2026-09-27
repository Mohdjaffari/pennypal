import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pages_app/components/Auth/LoginScreen.dart';
import 'package:pages_app/components/Auth/SignupScreen.dart';
import 'package:pages_app/components/Auth/ForgotPasswordScreen.dart';
import 'package:pages_app/screens/splash/splash_screen.dart';

void main() {
  testWidgets('LoginScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Login to your account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email or Phone'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('SignupScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignupScreen(),
      ),
    );

    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('Start your financial journey'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('ForgotPasswordScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ForgotPasswordScreen(),
      ),
    );

    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Send Recovery Code'), findsOneWidget);
    expect(find.text('Email or Phone'), findsOneWidget);
  });

  testWidgets('SplashScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(autoNavigate: false),
      ),
    );

    // Initial pump to let staggered animation advance
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Fresh All Along'), findsOneWidget);
    expect(find.text('Smart Money'), findsOneWidget);
    expect(find.text('Better Future'), findsOneWidget);
  });
}
