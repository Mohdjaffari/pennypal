import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'onboarding_model.dart';

/// Single Onboarding Page Slide matching the PennyPal UI design.
class OnboardingPageItem extends StatelessWidget {
  final OnboardingModel item;

  const OnboardingPageItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShortScreen = size.height < 680;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dynamic vertical spacer based on screen height
          SizedBox(height: isShortScreen ? 12 : 24),

          // 1. Hero Vector Illustration
          Expanded(
            flex: isShortScreen ? 4 : 5,
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: item.illustration,
              ),
            ),
          ),

          SizedBox(height: isShortScreen ? 16 : 28),

          // 2. Title & Subtitle block
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),

          // Space before the indicator and button
          SizedBox(height: isShortScreen ? 20 : 36),
        ],
      ),
    );
  }
}
