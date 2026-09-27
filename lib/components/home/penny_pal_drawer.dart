import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_service.dart';
import '../../core/localization/language_service.dart';
import '../../core/notifications/notification_service.dart';
import '../../screens/info/help_support_screen.dart';
import '../../screens/info/feedback_screen.dart';
import '../../screens/info/about_us_screen.dart';
import '../../screens/info/contact_us_screen.dart';
import '../../screens/info/privacy_policy_screen.dart';
import '../../screens/info/terms_conditions_screen.dart';


/// Premium navigation drawer for PennyPal.
/// Engineered with responsive Light & Dark theme support,
/// interactive appearance mode switcher, financial metrics pulse,
/// categorized navigation, and seamless state persistence.
class PennyPalDrawer extends StatefulWidget {
  final String userName;
  final String userRole;
  final String balance;
  final String expenses;
  final String savings;
  final int selectedIndex;
  final bool isLoggedIn;
  final ValueChanged<int>? onDestinationSelected;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;

  const PennyPalDrawer({
    super.key,
    this.userName = 'Mohd Jaffari',
    this.userRole = 'Student Plan',
    this.balance = 'Rs. 12,450',
    this.expenses = 'Rs. 8,230',
    this.savings = 'Rs. 3,200',
    this.selectedIndex = 0,
    this.isLoggedIn = false,
    this.onDestinationSelected,
    this.onProfileTap,
    this.onLogout,
    this.onLogin,
  });

  @override
  State<PennyPalDrawer> createState() => _PennyPalDrawerState();
}

class _PennyPalDrawerState extends State<PennyPalDrawer> {
  @override
  void initState() {
    super.initState();
    ThemeService.instance.addListener(_handleThemeChanged);
    LanguageService.instance.addListener(_handleThemeChanged);
    NotificationService.instance.addListener(_handleThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_handleThemeChanged);
    LanguageService.instance.removeListener(_handleThemeChanged);
    NotificationService.instance.removeListener(_handleThemeChanged);
    super.dispose();
  }

  void _handleThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleDarkModeToggle(bool enableDark) async {
    await ThemeService.instance.setDarkMode(enableDark);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              enableDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              enableDark ? 'Switched to Midnight Sapphire Theme' : 'Switched to Crisp Light Theme',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: enableDark ? const Color(0xFF1A2238) : const Color(0xFF1E2235),
        duration: const Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showThemeModeDialog() {
    final isDark = ThemeService.instance.isDark(context);
    final currentMode = ThemeService.instance.themeMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('select_theme'),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildThemeOptionTile(
                  ctx: ctx,
                  isDarkApp: isDark,
                  title: context.tr('crisp_light'),
                  subtitle: context.tr('crisp_light_desc'),
                  icon: Icons.wb_sunny_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  isSelected: currentMode == ThemeMode.light,
                  onTap: () {
                    Navigator.pop(ctx);
                    ThemeService.instance.setThemeMode(ThemeMode.light);
                  },
                ),
                const SizedBox(height: 8),
                _buildThemeOptionTile(
                  ctx: ctx,
                  isDarkApp: isDark,
                  title: context.tr('midnight_sapphire'),
                  subtitle: context.tr('midnight_sapphire_desc'),
                  icon: Icons.nightlight_round,
                  iconColor: const Color(0xFF818CF8),
                  isSelected: currentMode == ThemeMode.dark,
                  onTap: () {
                    Navigator.pop(ctx);
                    ThemeService.instance.setThemeMode(ThemeMode.dark);
                  },
                ),
                const SizedBox(height: 8),
                _buildThemeOptionTile(
                  ctx: ctx,
                  isDarkApp: isDark,
                  title: context.tr('system_auto'),
                  subtitle: context.tr('system_auto_desc'),
                  icon: Icons.settings_brightness_rounded,
                  iconColor: AppColors.primaryBlue,
                  isSelected: currentMode == ThemeMode.system,
                  onTap: () {
                    Navigator.pop(ctx);
                    ThemeService.instance.setThemeMode(ThemeMode.system);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionTile({
    required BuildContext ctx,
    required bool isDarkApp,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue.withValues(alpha: isDarkApp ? 0.22 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : (isDarkApp ? AppColors.darkBorder : AppColors.border),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDarkApp ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDarkApp ? AppColors.darkTextMuted : AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.instance.isDark(context);

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
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
            // 1. Sleek Profile Header with Gradient Accent & Verified Badge
            _DrawerProfileHeader(
              userName: widget.userName,
              userRole: widget.userRole,
              isDark: isDark,
              onTap: widget.onProfileTap != null
                  ? () {
                      Navigator.of(context).pop();
                      widget.onProfileTap!();
                    }
                  : null,
              onClose: () => Navigator.of(context).pop(),
            ),

            // 2. Quick Financial Pulse (Balance, Spent, Saved mini metrics)
            _DrawerQuickStats(
              balance: widget.balance,
              expenses: widget.expenses,
              savings: widget.savings,
              isDark: isDark,
              onStatTap: (index) {
                Navigator.of(context).pop();
                widget.onDestinationSelected?.call(index);
              },
            ),

            Divider(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              height: 1,
            ),

            // 3. Navigation Menu List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // --- Main Menu ---
                  _DrawerSectionHeader(title: context.tr('main_navigation').toUpperCase(), isDark: isDark),
                  _DrawerNavTile(
                    icon: Icons.dashboard_rounded,
                    title: context.tr('home'),
                    isActive: widget.selectedIndex == 0,
                    isDark: isDark,
                    onTap: () => _selectDestination(0),
                  ),
                  _DrawerNavTile(
                    icon: Icons.receipt_long_rounded,
                    title: context.tr('all_expenses'),
                    badgeText: context.tr('live_badge'),
                    badgeColor: AppColors.primaryPink,
                    isActive: widget.selectedIndex == 1,
                    isDark: isDark,
                    onTap: () => _selectDestination(1),
                  ),
                  _DrawerNavTile(
                    icon: Icons.pie_chart_rounded,
                    title: context.tr('budgets'),
                    subtitle: '55% ${context.tr('used_this_month')}',
                    isActive: widget.selectedIndex == 2,
                    isDark: isDark,
                    onTap: () => _selectDestination(2),
                  ),
                  _DrawerNavTile(
                    icon: Icons.track_changes_rounded,
                    title: context.tr('saving_goals'),
                    badgeText: '2 ${context.tr('active_badge')}',
                    badgeColor: AppColors.successGreen,
                    isActive: widget.selectedIndex == 3,
                    isDark: isDark,
                    onTap: () => _selectDestination(3),
                  ),
                  _DrawerNavTile(
                    icon: Icons.bar_chart_rounded,
                    title: context.tr('analytics'),
                    isActive: widget.selectedIndex == 4,
                    isDark: isDark,
                    onTap: () => _selectDestination(4),
                  ),

                  const SizedBox(height: 14),

                  // --- Penny AI Assistant Feature Card ---
                  _PennyAICard(
                    onTap: () => _selectDestination(5),
                  ),

                  const SizedBox(height: 14),

                  // --- Smart Tools ---
                  _DrawerSectionHeader(title: context.tr('learning_tools').toUpperCase(), isDark: isDark),
                  _DrawerNavTile(
                    icon: Icons.auto_stories_rounded,
                    title: context.tr('financial_learning'),
                    subtitle: context.tr('financial_learning_sub'),
                    isActive: widget.selectedIndex == 6,
                    isDark: isDark,
                    onTap: () => _selectDestination(6),
                  ),

                  const SizedBox(height: 14),

                  // --- Preferences & Theme Control ---
                  _DrawerSectionHeader(title: context.tr('preferences').toUpperCase(), isDark: isDark),

                  // PROFESSIONAL DARK & LIGHT MODE CONTROLLER TILE
                  _DrawerThemeTile(
                    isDark: isDark,
                    modeName: ThemeService.instance.themeModeName,
                    onToggle: _handleDarkModeToggle,
                    onOpenSelector: _showThemeModeDialog,
                  ),

                  _DrawerNavTile(
                    icon: Icons.notifications_none_rounded,
                    title: context.tr('notifications'),
                    badgeText: NotificationService.instance.unreadCount > 0
                        ? '${NotificationService.instance.unreadCount}'
                        : null,
                    badgeColor: AppColors.primaryPink,
                    isActive: widget.selectedIndex == 7,
                    isDark: isDark,
                    onTap: () => _selectDestination(7),
                  ),

                  _DrawerNavTile(
                    icon: Icons.settings_outlined,
                    title: context.tr('settings'),
                    isActive: widget.selectedIndex == 8,
                    isDark: isDark,
                    onTap: () => _selectDestination(8),
                  ),

                  _DrawerSwitchTile(
                    icon: NotificationService.instance.isPushActive
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    title: context.tr('push_alerts'),
                    subtitle: NotificationService.instance.isPushActive
                        ? context.tr('push_alerts_active')
                        : context.tr('push_alerts_muted'),
                    value: NotificationService.instance.pushAlertsEnabled,
                    isDark: isDark,
                    onChanged: (val) async {
                      await NotificationService.instance.setPushAlertsEnabled(val);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                val ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(val ? context.tr('push_alerts_active') : context.tr('push_alerts_muted')),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // --- Help & Support ---
                  _DrawerSectionHeader(title: context.tr('help_legal').toUpperCase(), isDark: isDark),
                  _DrawerNavTile(
                    icon: Icons.help_outline_rounded,
                    title: context.tr('help_faqs'),
                    isActive: false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                      );
                    },
                  ),
                  _DrawerNavTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Contact Support',
                    isActive: false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                      );
                    },
                  ),
                  _DrawerNavTile(
                    icon: Icons.rate_review_outlined,
                    title: context.tr('app_feedback'),
                    isActive: false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                      );
                    },
                  ),
                  _DrawerNavTile(
                    icon: Icons.info_outline_rounded,
                    title: context.tr('about_app'),
                    isActive: false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                      );
                    },
                  ),
                  _DrawerNavTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    isActive: false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                  _DrawerNavTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    isActive: false,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 4. Footer — Login (guest) or Logout (authenticated)
            _DrawerFooter(
              isDark: isDark,
              isLoggedIn: widget.isLoggedIn,
              onLogout: () {
                Navigator.of(context).pop();
                _confirmLogout(context, isDark);
              },
              onLogin: () {
                Navigator.of(context).pop();
                widget.onLogin?.call();
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

  void _confirmLogout(BuildContext context, bool isDark) {
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
              context.tr('sign_out'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('logout_message'),
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontSize: 13.5,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.tr('cancel'),
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
            child: Text(context.tr('logout'), style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUBCOMPONENTS
// ---------------------------------------------------------------------------

/// Top profile header with user info, status indicator, and close button
class _DrawerProfileHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback onClose;

  const _DrawerProfileHeader({
    required this.userName,
    required this.userRole,
    required this.isDark,
    this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
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
                      color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.45 : 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
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
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      width: 2,
                    ),
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
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
                    color: isDark
                        ? AppColors.primaryBlue.withValues(alpha: 0.2)
                        : AppColors.primaryBlueLight,
                    borderRadius: BorderRadius.circular(6),
                    border: isDark
                        ? Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.35), width: 0.8)
                        : null,
                  ),
                  child: Text(
                    userRole,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue,
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
                  color: isDark ? AppColors.darkBackground : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Mini financial stats banner showing Balance, Spent, and Saved
class _DrawerQuickStats extends StatelessWidget {
  final String balance;
  final String expenses;
  final String savings;
  final bool isDark;
  final ValueChanged<int> onStatTap;

  const _DrawerQuickStats({
    required this.balance,
    required this.expenses,
    required this.savings,
    required this.isDark,
    required this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            label: context.tr('total_balance'),
            value: balance,
            color: AppColors.primaryBlue,
            onTap: () => onStatTap(0),
          ),
          _buildDivider(),
          _buildStatItem(
            label: context.tr('expenses'),
            value: expenses,
            color: AppColors.primaryPink,
            onTap: () => onStatTap(1),
          ),
          _buildDivider(),
          _buildStatItem(
            label: context.tr('goals'),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 2),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
      color: isDark ? AppColors.darkBorder : AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// Promotional card highlighting Penny AI Assistant
class _PennyAICard extends StatelessWidget {
  final VoidCallback onTap;

  const _PennyAICard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
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
                color: const Color(0xFF7B61FF).withValues(alpha: 0.35),
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
                  children: [
                    Text(
                      context.tr('penny_ai'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('penny_ai_desc'),
                      style: const TextStyle(
                        color: Color(0xFFE2DCFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isRTL ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
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

/// Section header with letter spacing (suppressed for RTL languages)
class _DrawerSectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _DrawerSectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 10, bottom: 8, top: 6),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          // Letter-spacing breaks RTL scripts (Urdu, Arabic)
          letterSpacing: isRTL ? 0 : 1.1,
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
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerNavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.isActive = false,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark
        ? AppColors.primaryBlue.withValues(alpha: 0.24)
        : AppColors.primaryBlueLight;
    final activeColor = isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue;

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
                  ? Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.45 : 0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryBlue
                        : (isDark ? AppColors.darkBackground : AppColors.background),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isActive
                        ? Colors.white
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
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
                          color: isActive
                              ? activeColor
                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          fontSize: 13.5,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.4,
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
                      color: (badgeColor ?? AppColors.primaryBlue).withValues(alpha: isDark ? 0.22 : 0.12),
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

/// Professional Dark & Light Theme Controller Tile
/// Features an animated glowing sun/moon icon, mode subtitle,
/// an interactive switcher, and a shortcut to the theme modal.
class _DrawerThemeTile extends StatelessWidget {
  final bool isDark;
  final String modeName;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpenSelector;

  const _DrawerThemeTile({
    required this.isDark,
    required this.modeName,
    required this.onToggle,
    required this.onOpenSelector,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = isDark ? const Color(0xFF818CF8) : const Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenSelector,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceMuted.withValues(alpha: 0.6)
                  : AppColors.background.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Animated Glowing Sun / Moon Icon Box
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: isDark ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: isDark ? 0.25 : 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    color: themeColor,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),

                // Title & Active Mode Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Appearance',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              modeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDark ? 'Midnight Sapphire' : 'Crisp Light',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Fast Direct Toggle Switch
                Transform.scale(
                  scale: 0.85,
                  alignment: Alignment.centerRight,
                  child: Switch(
                    value: isDark,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryBlue,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.35),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: onToggle,
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

/// Switch toggle item for quick settings (e.g. notifications, push alerts)
class _DrawerSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _DrawerSwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primaryPink;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withValues(alpha: isDark ? 0.08 : 0.04)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: value
                    ? activeColor.withValues(alpha: isDark ? 0.35 : 0.2)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: value
                        ? activeColor.withValues(alpha: isDark ? 0.22 : 0.14)
                        : (isDark ? AppColors.darkBackground : AppColors.background),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: value
                        ? activeColor
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: value
                                ? (isDark ? const Color(0xFFF472B6) : activeColor)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                            fontSize: 11,
                            fontWeight: value ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Transform.scale(
                  scale: 0.85,
                  alignment: Alignment.centerRight,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    activeThumbColor: Colors.white,
                    activeTrackColor: activeColor,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.35),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

/// Drawer footer — brand watermark + context-aware auth button.
/// Shows a full "Log In" button for guests and a compact logout icon for logged-in users.
class _DrawerFooter extends StatelessWidget {
  final bool isDark;
  final bool isLoggedIn;
  final VoidCallback onLogout;
  final VoidCallback onLogin;

  const _DrawerFooter({
    required this.isDark,
    required this.isLoggedIn,
    required this.onLogout,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Brand row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.pinkGradient,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PennyPal',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Smart Money • Better Future',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Authenticated User: Full Logout Button ───────────────────────
          if (isLoggedIn) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded, size: 17, color: AppColors.expenseRed),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.expenseRed,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.expenseRed.withValues(alpha: isDark ? 0.45 : 0.3),
                    width: 1.2,
                  ),
                  backgroundColor: AppColors.expenseRed.withValues(alpha: isDark ? 0.12 : 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          // ── Guest User: Full Login / Create Account Button ──────────────
          if (!isLoggedIn) ...[
            const SizedBox(height: 12),
            // Guest notice strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.shoppingOrange.withValues(alpha: isDark ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.shoppingOrange.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      color: AppColors.shoppingOrange, size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Log in to unlock full features',
                      style: TextStyle(
                        color: AppColors.shoppingOrange,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Full-width Login CTA button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onLogin,
                  icon: const Icon(Icons.login_rounded, size: 17, color: Colors.white),
                  label: const Text(
                    'Log In / Create Account',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
