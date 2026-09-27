import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/theme_service.dart';

/// Interactive Dark / Light Mode Toggle Button for PennyPal Authentication screens.
/// Features smooth animated icon rotation, tactile haptic feedback,
/// and instant reactive synchronization with the central [ThemeService].
class AuthThemeToggleButton extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const AuthThemeToggleButton({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final isDark = ThemeService.instance.isDark(context);

        return Padding(
          padding: padding,
          child: Material(
            color: Colors.transparent,
            child: Tooltip(
              message: isDark ? 'Switch to Light mode' : 'Switch to Dark mode',
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ThemeService.instance.setDarkMode(!isDark);
                },
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF6366F1))
                            .withValues(alpha: isDark ? 0.16 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      key: ValueKey<bool>(isDark),
                      size: 19,
                      color: isDark
                          ? const Color(0xFFF59E0B) // Amber Sun
                          : const Color(0xFF6366F1), // Indigo Moon
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
