import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/auth/auth_service.dart';
import '../../components/home/home_header.dart';
import '../../components/profile/profile_header_card.dart';
import '../../components/profile/profile_menu_card.dart';
import '../../components/profile/edit_profile_sheet.dart';
import '../goals/savings_goals_screen.dart';
import '../notifications/notifications_screen.dart';
import '../info/help_support_screen.dart';
import '../info/about_us_screen.dart';
import '../info/contact_us_screen.dart';
import '../info/feedback_screen.dart';
import '../info/privacy_policy_screen.dart';
import '../info/terms_conditions_screen.dart';
import '../../components/Auth/LoginScreen.dart';

/// User Profile screen — PennyPal.
///
/// Features:
///   - Profile image picker (camera / gallery) with persistent storage
///   - Edit name & role via bottom sheet
///   - Full menu: Personal Info, My Goals, Notifications, Settings links, Legal screens
///   - Context-aware Logout / Login button at the bottom
///   - Working notification icon in app bar
class ProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialRole;
  final VoidCallback? onBack;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.initialName = 'Umair Khan',
    this.initialRole = 'Student',
    this.onBack,
    this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _userName;
  late String _userRole;
  String? _profileImagePath; // absolute path to picked image

  final _picker = ImagePicker();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _userName = widget.initialName;
    _userRole = widget.initialRole;
    _loadSavedUserData();
  }

  Future<void> _loadSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName');
    final savedImage = prefs.getString('profileImagePath');
    if (!mounted) return;
    setState(() {
      if (savedName != null && savedName.trim().isNotEmpty) {
        _userName = savedName.trim();
      }
      _profileImagePath = savedImage;
    });
  }

  // ── Profile Image Picker ─────────────────────────────────────────────────

  void _showImageSourceSheet() {
    final isDark = AppColors.isDark(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderOf(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Update Profile Photo',
                    style: TextStyle(
                      color: AppColors.textPrimaryOf(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Camera option
              _ImageSourceTile(
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                subtitle: 'Open camera to take a new photo',
                color: AppColors.primaryBlue,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),

              // Gallery option
              _ImageSourceTile(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                subtitle: 'Pick from your photo library',
                color: AppColors.primaryPink,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),

              // Remove option (only shown if image exists)
              if (_profileImagePath != null) ...[
                const SizedBox(height: 10),
                _ImageSourceTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Current Photo',
                  subtitle: 'Revert to initials avatar',
                  color: AppColors.expenseRed,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeImage();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', picked.path);
      setState(() => _profileImagePath = picked.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Profile photo updated!',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access camera/gallery. Please check permissions.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileImagePath');
    if (mounted) setState(() => _profileImagePath = null);
  }

  // ── Edit Profile ─────────────────────────────────────────────────────────

  void _openEditProfile() {
    EditProfileSheet.show(
      context,
      currentName: _userName,
      currentRole: _userRole,
      onSave: (data) async {
        final newName = data['name'] ?? _userName;
        final newRole = data['role'] ?? _userRole;
        setState(() {
          _userName = newName;
          _userRole = newRole;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', newName);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  void _confirmLogout() {
    final isDark = AppColors.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.expenseRed, size: 24),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of your PennyPal account?',
          style: TextStyle(
            color: AppColors.textSecondaryOf(context),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondaryOf(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService.instance.logout();
              widget.onLogout?.call();
              if (mounted) Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _push(Widget screen) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final isLoggedIn = AuthService.instance.isLoggedIn;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.backgroundOf(context),

        // ── App Bar ────────────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: AppColors.backgroundOf(context),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Profile',
            style: GoogleFonts.inter(
              color: AppColors.textPrimaryOf(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            // Notification icon — fully functional
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: HomeHeader.circularButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                tooltip: 'Notifications',
              ),
            ),
          ],
        ),

        // ── Body ──────────────────────────────────────────────────────────
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // 1. Profile Header (avatar + name + role)
                ProfileHeaderCard(
                  userName: _userName,
                  userRole: _userRole,
                  profileImagePath: _profileImagePath,
                  onEdit: _openEditProfile,
                  onEditPhoto: _showImageSourceSheet,
                ),

                const SizedBox(height: 32),

                // 2. Profile Actions Menu
                ProfileMenuCard(
                  onPersonalInfo: _openEditProfile,
                  onMyGoals: () => _push(const SavingsGoalsScreen()),
                  onNotificationSettings: () => _push(const NotificationsScreen()),
                  onHelpAndSupport: () => _push(const HelpSupportScreen()),
                  onContactSupport: () => _push(const ContactUsScreen()),
                  onSubmitFeedback: () => _push(const FeedbackScreen()),
                  onAboutApp: () => _push(const AboutUsScreen()),
                  onPrivacyPolicy: () => _push(const PrivacyPolicyScreen()),
                  onTermsOfService: () => _push(const TermsConditionsScreen()),
                ),

                const SizedBox(height: 28),

                // 3. Logout / Login button
                _AuthActionButton(
                  isLoggedIn: isLoggedIn,
                  isDark: isDark,
                  onLogout: _confirmLogout,
                  onLogin: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                    if ((result == true || AuthService.instance.isLoggedIn) && mounted) {
                      setState(() => _userName = AuthService.instance.userName);
                    }
                  },
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ────────────────────────────────────────────────────────────────────────────

/// Image source selection tile for the bottom sheet.
class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceMuted : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.textPrimaryOf(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondaryOf(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMutedOf(context),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Context-aware auth action: shows Logout for logged-in users, Login for guests.
class _AuthActionButton extends StatelessWidget {
  final bool isLoggedIn;
  final bool isDark;
  final VoidCallback onLogout;
  final VoidCallback onLogin;

  const _AuthActionButton({
    required this.isLoggedIn,
    required this.isDark,
    required this.onLogout,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      // ── Logout Button ──────────────────────────────────────────────────
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text(
            'Sign Out',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.expenseRed,
            side: BorderSide(
              color: AppColors.expenseRed.withValues(alpha: 0.5),
              width: 1.2,
            ),
            backgroundColor: AppColors.expenseRed.withValues(alpha: isDark ? 0.1 : 0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    // ── Login Button (Guest) ─────────────────────────────────────────────
    return Column(
      children: [
        // Guest label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.shoppingOrange.withValues(alpha: isDark ? 0.12 : 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.shoppingOrange.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.shoppingOrange, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You are browsing as a guest. Log in to unlock all features.',
                  style: TextStyle(
                    color: AppColors.shoppingOrange,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Login CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF43F5E),
                  Color(0xFFE11D48),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
              label: const Text(
                'Log In / Create Account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
