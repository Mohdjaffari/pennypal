import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../components/home/home_header.dart';
import '../splash/splash_screen.dart';

/// Screen displaying the "About Us" information for PennyPal.
/// Highlights the mission, student-centric philosophy, privacy principles,
/// core milestones, and development team details.
class AboutUsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const AboutUsScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeHeader(
        title: 'About PennyPal 💜',
        subtitle: 'Smart financial buddy for students',
        isBackNavigation: true,
        onMenuPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Brand Card
              _buildBrandHeroCard(context),
              const SizedBox(height: 22),

              // 2. Mission & Vision Statement
              _buildMissionCard(),
              const SizedBox(height: 20),

              // 3. Impact Metrics (3-column counters)
              _buildImpactMetrics(),
              const SizedBox(height: 26),

              // 4. Core Pillars
              const Text(
                'Why Students Trust PennyPal',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildPillarsList(),
              const SizedBox(height: 24),

              // 5. App & Version Information
              _buildAppInfoCard(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'PennyPal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Empowering Students to Master Their Money',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryPinkLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Version 1.2.0 • 2026 Edition',
              style: TextStyle(
                color: AppColors.primaryPink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Managing money during college, hostel life, or early career should never feel overwhelming. PennyPal replaces complicated spreadsheets with an intuitive, private, and motivating mobile companion that helps you budget smart and achieve your dreams.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetrics() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _metricItem('50K+', 'Students', AppColors.primaryPink),
          _divider(),
          _metricItem('Rs. 14M+', 'Logged', AppColors.primaryBlue),
          _divider(),
          _metricItem('99.9%', 'Privacy', AppColors.successGreen),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border,
    );
  }

  Widget _metricItem(String number, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarsList() {
    final pillars = [
      {
        'icon': Icons.lock_outline_rounded,
        'color': AppColors.successGreen,
        'bg': AppColors.successGreenLight,
        'title': '100% Privacy Focused',
        'subtitle':
            'Your financial entries are stored locally on your device. We do not sell or track your spending history.',
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'color': AppColors.purple,
        'bg': AppColors.purpleLight,
        'title': 'Penny AI Assistant',
        'subtitle':
            'Get real-time answers and smart budgeting recommendations designed specifically for allowance management.',
      },
      {
        'icon': Icons.track_changes_rounded,
        'color': AppColors.primaryPink,
        'bg': AppColors.primaryPinkLight,
        'title': 'Milestone-Based Goals',
        'subtitle':
            'Set target dates and monthly contribution guides to buy laptops, gear, or plan trips stress-free.',
      },
    ];

    return Column(
      children: pillars.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: p['bg'] as Color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(p['icon'] as IconData,
                    color: p['color'] as Color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Developer Team',
                  style: TextStyle(
                      fontSize: 13.5, color: AppColors.textSecondary)),
              Text('PennyPal Labs',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('License',
                  style: TextStyle(
                      fontSize: 13.5, color: AppColors.textSecondary)),
              Text('Student Free Tier',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Official Website',
                  style: TextStyle(
                      fontSize: 13.5, color: AppColors.textSecondary)),
              Text('pennypal.app',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPink)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SplashScreen(autoNavigate: false),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Replay Splash Screen 🎬',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.purple)),
                  Icon(Icons.play_circle_outline_rounded,
                      color: AppColors.purple, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
