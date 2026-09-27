import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Top profile header — displays avatar, name, and role.
///
/// Supports three avatar states:
///   1. User-picked image from device (via [profileImagePath])
///   2. Bundled asset fallback (assets/images/img2.jpg)
///   3. Initials gradient avatar if both image sources fail
///
/// The camera badge at bottom-right now calls [onEditPhoto] (full photo picker)
/// while the edit pencil badge calls [onEdit] (edit name/role).
class ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final String userRole;

  /// Absolute path to a user-picked image file, or null.
  final String? profileImagePath;

  /// Opens the name/role edit sheet.
  final VoidCallback onEdit;

  /// Opens the photo source picker (camera / gallery).
  final VoidCallback? onEditPhoto;

  const ProfileHeaderCard({
    super.key,
    required this.userName,
    this.userRole = 'Student',
    this.profileImagePath,
    required this.onEdit,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Avatar with pink accent ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    AppColors.primaryPink,
                    AppColors.primaryBlue,
                    AppColors.primaryPink,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceOf(context),
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: _buildAvatarImage(context),
                ),
              ),
            ),

            // Camera badge — opens photo picker
            Positioned(
              bottom: 2,
              right: 2,
              child: GestureDetector(
                onTap: onEditPhoto ?? onEdit,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceOf(context),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 2. User Name
        Text(
          userName,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppColors.textPrimaryOf(context),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 4),

        // 3. Role Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(
              alpha: AppColors.isDark(context) ? 0.2 : 0.08,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            userRole,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.primaryBlue,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 4. Edit profile text button
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded, size: 14),
          label: const Text('Edit Profile'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondaryOf(context),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),
      ],
    );
  }

  /// Builds the correct avatar widget: picked file → asset fallback → initials.
  Widget _buildAvatarImage(BuildContext context) {
    // Priority 1: user-picked image from device storage
    if (profileImagePath != null && profileImagePath!.isNotEmpty) {
      final file = File(profileImagePath!);
      return Image.file(
        file,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, s) => _buildInitialsAvatar(context),
      );
    }

    // Priority 2: bundled asset
    return Image.asset(
      'assets/images/img2.jpg',
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.6),
      errorBuilder: (ctx, e, s) => _buildInitialsAvatar(context),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        gradient: AppColors.blueGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
