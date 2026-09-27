import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable tile for navigable settings items (Language, Help, Privacy, Terms).
class SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
        style: TextStyle(
          color: AppColors.textPrimaryOf(context),
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: AppColors.textSecondaryOf(context),
                fontSize: 12.5,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMutedOf(context),
        size: 22,
      ),
    );
  }
}
