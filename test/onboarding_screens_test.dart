import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pages_app/components/onboardscreens.dart';
import 'package:pages_app/components/onboarding/onboarding_illustrations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  testWidgets('Onboarding flow displays screens and transitions properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreens(),
      ),
    );

    // Initial Screen 1
    expect(find.text('Track Your Expenses'), findsOneWidget);
    expect(
      find.text('Keep a record of your daily expenses and know where your money goes.'),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.byType(WalletExpenseIllustration), findsOneWidget);
    expect(find.byType(SmoothPageIndicator), findsOneWidget);

    // Tap Next to navigate to Screen 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Set Your Budget'), findsOneWidget);
    expect(
      find.text('Plan your monthly budget and stay on track with your goals.'),
      findsOneWidget,
    );
    expect(find.byType(BudgetChartIllustration), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap Next to navigate to Screen 3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Save for Your Dreams'), findsOneWidget);
    expect(
      find.text('Create savings goals and build a better tomorrow.'),
      findsOneWidget,
    );
    expect(find.byType(PiggyBankIllustration), findsOneWidget);
    expect(find.text('Get Started'), findsWidgets); // Button and Top Right
  });
}
