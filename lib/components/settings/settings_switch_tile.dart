import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable tile for toggleable settings items (Dark Mode, Push Notifications).
class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primaryBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.primaryBlue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        value: value,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.primaryPink,
        onChanged: onChanged,
      ),
    );
  }
}
