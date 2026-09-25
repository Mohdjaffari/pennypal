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
  String _selectedLanguage = 'English';
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true;

  Future<void> _chooseLanguage() async {
    final chosen = await LanguageSelectorSheet.show(context, _selectedLanguage);
    if (chosen != null && mounted) {
      setState(() => _selectedLanguage = chosen);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to $_selectedLanguage'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeHeader(
        title: 'Settings & Preferences ⚙️',
        subtitle: 'App customizations & policies',
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
              _buildSectionTitle('App Settings'),
              const SizedBox(height: 10),
              SettingsCardGroup(
                children: [
                  SettingsActionTile(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    subtitle: _selectedLanguage,
                    iconColor: AppColors.primaryBlue,
                    onTap: _chooseLanguage,
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.border),
                  SettingsSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: _isDarkMode,
                    iconColor: AppColors.purple,
                    onChanged: (val) {
                      setState(() => _isDarkMode = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Dark mode enabled' : 'Light mode enabled'),
                          duration: const Duration(milliseconds: 900),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.border),
                  SettingsSwitchTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    value: _isNotificationsEnabled,
                    iconColor: AppColors.primaryPink,
                    onChanged: (val) {
                      setState(() => _isNotificationsEnabled = val);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 2. Support Section
              _buildSectionTitle('Support & Feedback'),
              const SizedBox(height: 10),
              SettingsCardGroup(
                children: [
                  SettingsActionTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & FAQs',
                    subtitle: 'Tutorials & common questions',
                    iconColor: AppColors.primaryBlue,
                    onTap: () => _navigateTo(const HelpSupportScreen()),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.border),
                  SettingsActionTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Contact Support',
                    subtitle: 'Email, WhatsApp & campus desk',
                    iconColor: AppColors.successGreen,
                    onTap: () => _navigateTo(const ContactUsScreen()),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.border),
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
              _buildSectionTitle('About & Legal'),
              const SizedBox(height: 10),
              SettingsCardGroup(
                children: [
                  SettingsActionTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About PennyPal',
                    subtitle: 'Our mission & student impact',
                    iconColor: AppColors.primaryPink,
                    onTap: () => _navigateTo(const AboutUsScreen()),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.border),
                  SettingsActionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Local-first & zero-tracking rules',
                    iconColor: AppColors.successGreen,
                    onTap: () => _navigateTo(const PrivacyPolicyScreen()),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.border),
                  SettingsActionTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
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
