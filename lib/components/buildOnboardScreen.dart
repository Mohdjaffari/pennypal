// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Legacy helper for building an onboarding screen item.
/// Updated to conform to PennyPal typography and color palettes.
Widget buildOnboardScreen(
  dynamic imageOrWidget,
  String title,
  String description, [
  Color backgroundColor = Colors.white,
]) {
  return Container(
    color: backgroundColor,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Hero visual
            Expanded(
              flex: 8,
              child: Center(
                child: imageOrWidget is Widget
                    ? imageOrWidget
                    : (imageOrWidget is String && imageOrWidget.isNotEmpty)
                        ? Image.asset(imageOrWidget, fit: BoxFit.contain)
                        : const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    ),
  );
}