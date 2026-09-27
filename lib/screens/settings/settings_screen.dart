import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../components/settings/settings_card_group.dart';
import '../../components/settings/settings_action_tile.dart';
import '../../components/settings/settings_switch_tile.dart';
import '../../components/settings/language_selector_sheet.dart';
import '../../components/home/home_header.dart';
import '../info/about_us_screen.dart';
import '../info/contact_us_screen.dart';
import '../info/feedback_screen.dart';
import '../info/help_support_screen.dart';
import '../info/terms_conditions_screen.dart';
import '../info/privacy_policy_screen.dart';

import '../../core/theme/theme_service.dart';
import '../../core/localization/language_service.dart';
import '../../core/notifications/notification_service.dart';

/// Screen representing the Settings view in PennyPal (Screen 10).
/// Rebuilt with clean modular architecture, interactive language selector,
/// real legal & support screens routing, and persistent preference toggles.
class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    ThemeService.instance.addListener(_onStateChanged);
    LanguageService.instance.addListener(_onStateChanged);
    NotificationService.instance.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onStateChanged);
    LanguageService.instance.removeListener(_onStateChanged);
    NotificationService.instance.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _chooseLanguage() async {
    final chosen = await LanguageSelectorSheet.show(
      context,
      LanguageService.instance.currentLanguage,
    );
    if (chosen != null && mounted) {
      await LanguageService.instance.setLanguage(chosen);
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('language')}: $chosen'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      });
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.instance.isDark(context);
    final borderColor = AppColors.borderOf(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: HomeHeader(
        title: '${context.tr('settings')} ⚙️',
        subtitle: context.tr('preferences'),
        isBackNavigation: true,
        onMenuPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Settings Section
              _buildSectionTitle(context.tr('preferences')),
              const SizedBox(height: 10),
              SettingsCardGroup(
                children: [
                  SettingsActionTile(
                    icon: Icons.language_rounded,
                    title: context.tr('language'),
                    subtitle: LanguageService.instance.currentLanguage,
                    iconColor: AppColors.primaryBlue,
                    onTap: _chooseLanguage,
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: borderColor),
                  SettingsSwitchTile(
                    icon: isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    title: context.tr('dark_mode'),
                    value: isDark,
                    iconColor: isDark ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
                    onChanged: (val) async {
                      await ThemeService.instance.setDarkMode(val);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Dark mode enabled' : 'Light mode enabled'),
                          duration: const Duration(milliseconds: 900),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: borderColor),
                  SettingsSwitchTile(
                    icon: NotificationService.instance.notificationsEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    title: context.tr('enable_notifications'),
                    subtitle: NotificationService.instance.notificationsEnabled
                        ? 'Real-time alert notifications active'
                        : 'All notifications muted',
                    value: NotificationService.instance.notificationsEnabled,
                    iconColor: NotificationService.instance.notificationsEnabled
                        ? AppColors.primaryPink
                        : AppColors.textSecondaryOf(context),
                    onChanged: (val) async {
                      await NotificationService.instance.setNotificationsEnabled(val);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                val
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_off_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(val
                                  ? '🔔 Notifications enabled'
                                  : '🔕 Notifications muted'),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          action: val
                              ? SnackBarAction(
                                  label: 'TEST',
                                  textColor: AppColors.primaryPink,
                                  onPressed: () => NotificationService.instance
                                      .triggerTestAlert(context),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  if (NotificationService.instance.notificationsEnabled) ...[
                    Divider(height: 1, indent: 20, endIndent: 20, color: borderColor),
                    SettingsSwitchTile(
                      icon: NotificationService.instance.pushAlertsEnabled
                          ? Icons.bolt_rounded
                          : Icons.notifications_paused_outlined,
                      title: 'Push Alert Banners',
                      subtitle: 'Floating popup banners for urgent warnings',
                      value: NotificationService.instance.pushAlertsEnabled,
                      iconColor: NotificationService.instance.pushAlertsEnabled
                          ? const Color(0xFFF59E0B)
                          : AppColors.textSecondaryOf(context),
                      onChanged: (val) async {
                        await NotificationService.instance.setPushAlertsEnabled(val);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        if (val) {
                          NotificationService.instance.triggerTestAlert(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.notifications_paused_rounded,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 10),
                                  Text('🔕 Push alert banners paused'),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                    ),
                    Divider(height: 1, indent: 20, endIndent: 20, color: borderColor),
                    SettingsActionTile(
                      icon: Icons.send_rounded,
                      title: 'Send Test Push Alert',
                      subtitle: 'Simulate a real-time spending warning banner',
                      iconColor: AppColors.primaryBlue,
                      onTap: () =>
                          NotificationService.instance.triggerTestAlert(context),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 28),

              // 2. Support Section
              _buildSectionTitle(context.tr('help_support')),
              const SizedBox(height: 10),
              SettingsCardGroup(
                children: [
                  SettingsActionTile(
                    icon: Icons.help_outline_rounded,
                    title: context.tr('help_support'),
                    subtitle: 'Tutorials & common questions',
                    iconColor: AppColors.primaryBlue,
                    onTap: () => _navigateTo(const HelpSupportScreen()),
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: borderColor),
                  SettingsActionTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Contact Support',
                    subtitle: 'Email, WhatsApp & campus desk',
                    iconColor: AppColors.successGreen,
                    onTap: () => _navigateTo(const ContactUsScreen()),
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: borderColor),
                  SettingsActionTile(
                    icon: Icons.rate_review_outlined,
                    title: 'Submit Feedback',
                    subtitle: 'Rate app & suggest features',
                    iconColor: AppColors.purple,
                    onTap: () => _navigateTo(const FeedbackScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 3. About & Legal Section
              _buildSectionTitle(context.tr('about_app')),
              const SizedBox(height: 10),
              SettingsCardGroup(
                children: [
                  SettingsActionTile(
                    icon: Icons.info_outline_rounded,
                    title: context.tr('about_app'),
                    subtitle: 'Our mission & student impact',
                    iconColor: AppColors.primaryPink,
                    onTap: () => _navigateTo(const AboutUsScreen()),
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: borderColor),
                  SettingsActionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: context.tr('privacy_policy'),
                    subtitle: 'Local-first & zero-tracking rules',
                    iconColor: AppColors.successGreen,
                    onTap: () => _navigateTo(const PrivacyPolicyScreen()),
                  ),
                  Divider(height: 1, indent: 20, endIndent: 20, color: borderColor),
                  SettingsActionTile(
                    icon: Icons.description_outlined,
                    title: context.tr('terms_service'),
                    subtitle: 'Rules, disclaimer & user guidelines',
                    iconColor: AppColors.shoppingOrange,
                    onTap: () => _navigateTo(const TermsConditionsScreen()),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // App Version Watermark
              Center(
                child: Text(
                  'PennyPal v1.0.0 (Build 102)',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
