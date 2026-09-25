import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/info/help_support_screen.dart';
import '../../screens/info/feedback_screen.dart';
import '../../screens/info/about_us_screen.dart';

/// Premium navigation drawer designed to match the PennyPal design system.
/// Features a profile banner, quick financial stats, smart AI assistant card,
/// categorized navigation, interactive toggles, and logout handling.
class PennyPalDrawer extends StatefulWidget {
  final String userName;
  final String userRole;
  final String balance;
  final String expenses;
  final String savings;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final VoidCallback? onLogout;

  const PennyPalDrawer({
    super.key,
    this.userName = 'Mohd Jaffari',
    this.userRole = 'Student Plan',
    this.balance = 'Rs. 12,450',
    this.expenses = 'Rs. 8,230',
    this.savings = 'Rs. 3,200',
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.onLogout,
  });

  @override
  State<PennyPalDrawer> createState() => _PennyPalDrawerState();
}

class _PennyPalDrawerState extends State<PennyPalDrawer> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Sleek Profile Header with Gradient Accent
            _DrawerProfileHeader(
              userName: widget.userName,
              userRole: widget.userRole,
              onClose: () => Navigator.of(context).pop(),
            ),

            // 2. Quick Financial Pulse (Balance, Spent, Saved mini metrics)
            _DrawerQuickStats(
              balance: widget.balance,
              expenses: widget.expenses,
              savings: widget.savings,
              onStatTap: (index) {
                Navigator.of(context).pop();
                widget.onDestinationSelected?.call(index);
              },
            ),

            const Divider(color: AppColors.border, height: 1),

            // 3. Navigation Menu List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // --- Main Menu ---
                  const _DrawerSectionHeader(title: 'MAIN NAVIGATION'),
                  _DrawerNavTile(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isActive: widget.selectedIndex == 0,
                    onTap: () => _selectDestination(0),
                  ),
                  _DrawerNavTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'All Expenses',
                    badgeText: 'New',
                    badgeColor: AppColors.primaryPink,
                    isActive: widget.selectedIndex == 1,
                    onTap: () => _selectDestination(1),
                  ),
                  _DrawerNavTile(
                    icon: Icons.pie_chart_rounded,
                    title: 'Budgets',
                    subtitle: '55% used this month',
                    isActive: widget.selectedIndex == 2,
                    onTap: () => _selectDestination(2),
                  ),
                  _DrawerNavTile(
                    icon: Icons.track_changes_rounded,
                    title: 'Savings Goals',
                    badgeText: '2 Active',
                    badgeColor: AppColors.successGreen,
                    isActive: widget.selectedIndex == 3,
                    onTap: () => _selectDestination(3),
                  ),
                  _DrawerNavTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports & Analytics',
                    isActive: widget.selectedIndex == 4,
                    onTap: () => _selectDestination(4),
                  ),

                  const SizedBox(height: 14),

                  // --- Penny AI Assistant Feature Card ---
                  _PennyAICard(
                    onTap: () => _selectDestination(5),
                  ),

                  const SizedBox(height: 14),

                  // --- Smart Tools ---
                  const _DrawerSectionHeader(title: 'LEARNING & TOOLS'),
                  _DrawerNavTile(
                    icon: Icons.auto_stories_rounded,
                    title: 'Financial Learning',
                    subtitle: 'Smart Budgeting 101',
                    isActive: widget.selectedIndex == 6,
                    onTap: () => _selectDestination(6),
                  ),

                  const SizedBox(height: 14),

                  // --- Preferences ---
                  const _DrawerSectionHeader(title: 'PREFERENCES'),
                  _DrawerNavTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    badgeText: '3',
                    badgeColor: AppColors.primaryPink,
                    isActive: widget.selectedIndex == 7,
                    onTap: () => _selectDestination(7),
                  ),
                  _DrawerNavTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    isActive: widget.selectedIndex == 8,
                    onTap: () => _selectDestination(8),
                  ),

                  // Quick Dark Mode Switcher (Matching Settings screen in design board)
                  _DrawerSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: _darkMode,
                    onChanged: (val) {
                      setState(() => _darkMode = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Dark mode enabled' : 'Light mode enabled'),
                          duration: const Duration(milliseconds: 900),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _DrawerSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Push Alerts',
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                    },
                  ),

                  const SizedBox(height: 14),

                  // --- Help & Support ---
                  const _DrawerSectionHeader(title: 'HELP & LEGAL'),
                  _DrawerNavTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & FAQs',
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                      );
                    },
                  ),
                  _DrawerNavTile(
                    icon: Icons.rate_review_outlined,
                    title: 'App Feedback',
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                      );
                    },
                  ),
                  _DrawerNavTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About PennyPal',
                    isActive: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 4. Footer with PennyPal brand watermark & Logout action
            _DrawerFooter(
              onLogout: () {
                Navigator.of(context).pop();
                _confirmLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectDestination(int index) {
    Navigator.of(context).pop();
    widget.onDestinationSelected?.call(index);
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.expenseRed, size: 24),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of PennyPal? Your financial data will remain securely saved.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onLogout?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUBCOMPONENTS (HUMAN-READABLE COMPONENT ARCHITECTURE)
// ---------------------------------------------------------------------------

/// Top profile header with user info and close action
class _DrawerProfileHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback onClose;

  const _DrawerProfileHeader({
    required this.userName,
    required this.userRole,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          // Avatar with gradient border & verified indicator
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'J',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // User Name & Plan/Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    userRole,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini financial stats banner showing Balance, Spent, and Saved
class _DrawerQuickStats extends StatelessWidget {
  final String balance;
  final String expenses;
  final String savings;
  final ValueChanged<int> onStatTap;

  const _DrawerQuickStats({
    required this.balance,
    required this.expenses,
    required this.savings,
    required this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildStatItem(
            label: 'Balance',
            value: balance,
            color: AppColors.primaryBlue,
            onTap: () => onStatTap(0),
          ),
          _buildDivider(),
          _buildStatItem(
            label: 'Spent',
            value: expenses,
            color: AppColors.primaryPink,
            onTap: () => onStatTap(1),
          ),
          _buildDivider(),
          _buildStatItem(
            label: 'Saved',
            value: savings,
            color: AppColors.successGreen,
            onTap: () => onStatTap(3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// Promotional card highlighting Penny AI Assistant (Screen 7 from board)
class _PennyAICard extends StatelessWidget {
  final VoidCallback onTap;

  const _PennyAICard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B61FF), Color(0xFF6246EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B61FF).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ask Penny AI Buddy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Smart answers about savings',
                      style: TextStyle(
                        color: Color(0xFFE2DCFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean letter-spaced section header
class _DrawerSectionHeader extends StatelessWidget {
  final String title;

  const _DrawerSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8, top: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// Navigation Tile with active pill highlight, icons, subtitles, and badges
class _DrawerNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerNavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = AppColors.primaryBlueLight;
    final activeColor = AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isActive
                  ? Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isActive ? activeColor : AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),

                // Badge Tag
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppColors.primaryBlue).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        color: badgeColor ?? AppColors.primaryBlue,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Switch toggle item for quick settings (Dark mode, notifications)
class _DrawerSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DrawerSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primaryBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

/// Drawer footer showing PennyPal app brand watermark and logout button
class _DrawerFooter extends StatelessWidget {
  final VoidCallback onLogout;

  const _DrawerFooter({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + Branding
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.pinkGradient,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'PennyPal',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Smart Money • Better Future',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Logout Icon Button with smooth ripple
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.expenseRedLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.expenseRed,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
