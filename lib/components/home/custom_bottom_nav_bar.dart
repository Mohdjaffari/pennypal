import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_service.dart';

/// Navigation bar item definition.
class NavigationTabItem {
  final IconData icon;
  final String label;

  const NavigationTabItem({
    required this.icon,
    required this.label,
  });
}

/// Custom BottomAppBar designed for PennyPal with notch integration for center FAB.
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final leftTabs = [
      NavigationTabItem(icon: Icons.home_rounded, label: context.tr('home')),
      NavigationTabItem(icon: Icons.receipt_long_rounded, label: context.tr('expenses')),
    ];

    final rightTabs = [
      NavigationTabItem(icon: Icons.track_changes_rounded, label: context.tr('goals')),
      NavigationTabItem(icon: Icons.person_outline_rounded, label: context.tr('profile')),
    ];

    return BottomAppBar(
      color: AppColors.surfaceOf(context),
      surfaceTintColor: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 62,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left navigation items (Home, Expenses)
              ...List.generate(
                leftTabs.length,
                (i) => _buildNavItem(
                  context: context,
                  isDark: isDark,
                  item: leftTabs[i],
                  isSelected: selectedIndex == i,
                  onTap: () => onTabSelected(i),
                ),
              ),

              // Reserved spacer in the middle for center FAB
              const SizedBox(width: 48),

              // Right navigation items (Goals, Profile)
              ...List.generate(
                rightTabs.length,
                (i) {
                  final actualIndex = i + leftTabs.length;
                  return _buildNavItem(
                    context: context,
                    isDark: isDark,
                    item: rightTabs[i],
                    isSelected: selectedIndex == actualIndex,
                    onTap: () => onTabSelected(actualIndex),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required bool isDark,
    required NavigationTabItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue;
    final inactiveColor = AppColors.textMutedOf(context);
    final color = isSelected ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
