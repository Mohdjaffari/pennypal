import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'onboarding_illustrations.dart';

/// Data representation for an Onboarding slide
class OnboardingModel {
  final String title;
  final String description;
  final Widget illustration;
  final String buttonText;
  final Color buttonColor;
  final bool isLast;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.illustration,
    required this.buttonText,
    required this.buttonColor,
    this.isLast = false,
  });

  /// The 3 official PennyPal onboarding screens directly extracted from design
  static List<OnboardingModel> get screens => const [
        OnboardingModel(
          title: 'Track Your Expenses',
          description:
              'Keep a record of your daily expenses and know where your money goes.',
          illustration: WalletExpenseIllustration(),
          buttonText: 'Next',
          buttonColor: AppColors.primaryBlue,
        ),
        OnboardingModel(
          title: 'Set Your Budget',
          description:
              'Plan your monthly budget and stay on track with your goals.',
          illustration: BudgetChartIllustration(),
          buttonText: 'Next',
          buttonColor: AppColors.primaryBlue,
        ),
        OnboardingModel(
          title: 'Save for Your Dreams',
          description:
              'Create savings goals and build a better tomorrow.',
          illustration: PiggyBankIllustration(),
          buttonText: 'Get Started',
          buttonColor: AppColors.primaryPink,
          isLast: true,
        ),
      ];
}
