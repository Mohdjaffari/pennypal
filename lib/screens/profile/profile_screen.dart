import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../components/profile/profile_header_card.dart';
import '../../components/profile/financial_health_chart_card.dart';
import '../../components/profile/profile_menu_card.dart';
import '../../components/profile/edit_profile_sheet.dart';
import '../../components/home/home_header.dart';
import '../goals/savings_goals_screen.dart';
import '../notifications/notifications_screen.dart';
import '../info/help_support_screen.dart';
import '../info/about_us_screen.dart';

/// Screen representing the User Profile view in PennyPal (Screen 9).
/// Rebuilt with clean modular architecture, interactive financial health chart,
/// and integrated goal/notification/personal info routing.
class ProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialRole;
  final VoidCallback? onBack;

  const ProfileScreen({
    super.key,
    this.initialName = 'Mohd Jaffari',
    this.initialRole = 'Student Plan',
    this.onBack,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _userName;
  late String _userRole;

  @override
  void initState() {
    super.initState();
    _userName = widget.initialName;
    _userRole = widget.initialRole;
  }

  void _openEditProfile() {
    EditProfileSheet.show(
      context,
      currentName: _userName,
      currentRole: _userRole,
      onSave: (data) {
        setState(() {
          _userName = data['name']!;
          _userRole = data['role']!;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeHeader(
        title: 'My Profile 👤',
        subtitle: 'Account & financial health overview',
        isBackNavigation: true,
        onMenuPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        onNotificationPressed: _openEditProfile,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              // 1. User Avatar, Name, Role & Balance Summary
              ProfileHeaderCard(
                userName: _userName,
                userRole: _userRole,
                balance: 'Rs. 12,450',
                savings: 'Rs. 3,200',
                onEdit: _openEditProfile,
              ),
              const SizedBox(height: 24),

              // 2. Financial Health Score Chart & Savings Rate Gauge
              const FinancialHealthChartCard(
                score: 82,
                savingsRate: 0.65,
                budgetAdherence: 0.55,
              ),
              const SizedBox(height: 24),

              // 3. Settings & Navigation Menu
              ProfileMenuCard(
                onPersonalInfo: _openEditProfile,
                onMyGoals: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SavingsGoalsScreen(),
                    ),
                  );
                },
                onNotificationSettings: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                onHelpAndSupport: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
                onAboutApp: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AboutUsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
