import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Card container hosting the profile navigation menu items,
/// replicating Screen 9 from the PennyPal Figma board.
class ProfileMenuCard extends StatelessWidget {
  final VoidCallback onPersonalInfo;
  final VoidCallback onMyGoals;
  final VoidCallback onNotificationSettings;
  final VoidCallback onHelpAndSupport;
  final VoidCallback onAboutApp;

  const ProfileMenuCard({
    super.key,
    required this.onPersonalInfo,
    required this.onMyGoals,
    required this.onNotificationSettings,
    required this.onHelpAndSupport,
    required this.onAboutApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              iconColor: AppColors.primaryBlue,
              onTap: onPersonalInfo,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.track_changes_rounded,
              title: 'My Goals',
              iconColor: AppColors.primaryPink,
              onTap: onMyGoals,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notification Settings',
              iconColor: AppColors.purple,
              onTap: onNotificationSettings,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              iconColor: AppColors.shoppingOrange,
              onTap: onHelpAndSupport,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'About App',
              iconColor: AppColors.successGreen,
              onTap: onAboutApp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.8,
      color: AppColors.border,
      indent: 66,
      endIndent: 16,
    );
  }
}
