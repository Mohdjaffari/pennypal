import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

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

  static const List<NavigationTabItem> leftTabs = [
    NavigationTabItem(icon: Icons.home_rounded, label: 'Home'),
    NavigationTabItem(icon: Icons.receipt_long_rounded, label: 'Expenses'),
  ];

  static const List<NavigationTabItem> rightTabs = [
    NavigationTabItem(icon: Icons.track_changes_rounded, label: 'Goals'),
    NavigationTabItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
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
    required NavigationTabItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? AppColors.primaryBlue : AppColors.textMuted;

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
