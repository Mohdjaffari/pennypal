import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Profile actions menu card — all profile-related and app info links.
///
/// Sections:
///   Account — Personal Information, My Goals, Notification Settings
///   Support — Help & FAQs, Contact Support, Submit Feedback
///   Legal   — About PennyPal, Privacy Policy, Terms of Service
class ProfileMenuCard extends StatelessWidget {
  // Account section
  final VoidCallback onPersonalInfo;
  final VoidCallback onMyGoals;
  final VoidCallback onNotificationSettings;

  // Support section
  final VoidCallback onHelpAndSupport;
  final VoidCallback onContactSupport;
  final VoidCallback onSubmitFeedback;

  // Legal / Info section
  final VoidCallback onAboutApp;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTermsOfService;

  const ProfileMenuCard({
    super.key,
    required this.onPersonalInfo,
    required this.onMyGoals,
    required this.onNotificationSettings,
    required this.onHelpAndSupport,
    required this.onContactSupport,
    required this.onSubmitFeedback,
    required this.onAboutApp,
    required this.onPrivacyPolicy,
    required this.onTermsOfService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Account Section ────────────────────────────────────────────────
        _SectionLabel(label: 'ACCOUNT'),
        const SizedBox(height: 8),
        _MenuGroup(
          children: [
            _MenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              subtitle: 'Name, role & account details',
              iconColor: AppColors.primaryBlue,
              onTap: onPersonalInfo,
            ),
            _MenuItem(
              icon: Icons.track_changes_rounded,
              title: 'My Goals',
              subtitle: 'Savings targets & milestones',
              iconColor: AppColors.primaryPink,
              onTap: onMyGoals,
            ),
            _MenuItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notification Settings',
              subtitle: 'Alerts & push notification control',
              iconColor: AppColors.purple,
              isLast: true,
              onTap: onNotificationSettings,
            ),
          ],
        ),

        const SizedBox(height: 22),

        // ── Support Section ────────────────────────────────────────────────
        _SectionLabel(label: 'SUPPORT'),
        const SizedBox(height: 8),
        _MenuGroup(
          children: [
            _MenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & FAQs',
              subtitle: 'Tutorials & common questions',
              iconColor: AppColors.shoppingOrange,
              onTap: onHelpAndSupport,
            ),
            _MenuItem(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Contact Support',
              subtitle: 'Email, WhatsApp & campus desk',
              iconColor: AppColors.successGreen,
              onTap: onContactSupport,
            ),
            _MenuItem(
              icon: Icons.rate_review_outlined,
              title: 'Submit Feedback',
              subtitle: 'Rate the app & suggest features',
              iconColor: AppColors.purple,
              isLast: true,
              onTap: onSubmitFeedback,
            ),
          ],
        ),

        const SizedBox(height: 22),

        // ── Legal / About Section ─────────────────────────────────────────
        _SectionLabel(label: 'ABOUT'),
        const SizedBox(height: 8),
        _MenuGroup(
          children: [
            _MenuItem(
              icon: Icons.info_outline_rounded,
              title: 'About PennyPal',
              subtitle: 'Our mission & student impact',
              iconColor: AppColors.primaryBlue,
              onTap: onAboutApp,
            ),
            _MenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Local-first & zero-tracking rules',
              iconColor: AppColors.successGreen,
              onTap: onPrivacyPolicy,
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Rules, disclaimer & user guidelines',
              iconColor: AppColors.shoppingOrange,
              isLast: true,
              onTap: onTermsOfService,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// Card container wrapping a group of menu items.
class _MenuGroup extends StatelessWidget {
  final List<Widget> children;
  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderOf(context), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }
}

/// A single tappable menu row with icon bubble, title, subtitle and chevron.
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.iconColor,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Row(
                children: [
                  // Icon bubble
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),

                  // Title + optional subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimaryOf(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: AppColors.textSecondaryOf(context),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMutedOf(context),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: AppColors.borderOf(context),
            indent: 70,
            endIndent: 16,
          ),
      ],
    );
  }
}
