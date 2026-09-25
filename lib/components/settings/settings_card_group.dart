import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Card container grouping related settings tiles together.
class SettingsCardGroup extends StatelessWidget {
  final List<Widget> children;

  const SettingsCardGroup({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
