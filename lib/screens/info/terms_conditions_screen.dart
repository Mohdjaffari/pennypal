import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../components/home/home_header.dart';

/// Screen displaying the official Terms and Conditions for PennyPal.
/// Formatted with human-readable summaries, legal disclosure sections,
/// student data ownership clauses, and an interactive agreement footer.
class TermsConditionsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const TermsConditionsScreen({super.key, this.onBack});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _agreed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeHeader(
        title: 'Terms of Service 📜',
        subtitle: 'Updated: September 2026',
        isBackNavigation: true,
        onMenuPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Plain English Summary Card
              _buildSummaryCard(),
              const SizedBox(height: 24),

              // 2. Section 1: Agreement to Terms
              _buildSection(
                number: '01',
                title: 'Acceptance of Terms',
                icon: Icons.assignment_turned_in_outlined,
                color: AppColors.primaryBlue,
                content:
                    'By downloading, installing, or using the PennyPal mobile application, you acknowledge that you have read, understood, and agreed to be bound by these terms. If you are under 18 years of age, you represent that your parent or legal guardian has reviewed and agreed to these terms on your behalf.',
              ),
              const SizedBox(height: 16),

              // 3. Section 2: Educational Nature & Financial Disclaimer
              _buildSection(
                number: '02',
                title: 'Educational Financial Disclaimer',
                icon: Icons.shield_outlined,
                color: AppColors.shoppingOrange,
                content:
                    'PennyPal is a student budgeting and personal finance tracker designed for educational, organizational, and planning purposes. PennyPal and its AI assistant (Penny) do NOT provide certified financial planning, tax advice, investment brokering, or legal counsel. All spending recommendations are informational benchmarks.',
              ),
              const SizedBox(height: 16),

              // 4. Section 3: Data Ownership & Storage
              _buildSection(
                number: '03',
                title: '100% User Data Ownership',
                icon: Icons.fingerprint_rounded,
                color: AppColors.successGreen,
                content:
                    'You retain complete, exclusive ownership of all transaction logs, receipts, categories, budgets, and savings goals entered into PennyPal. The app utilizes client-side local database storage to guarantee that your financial habits are never monetized, rented, or distributed to third parties.',
              ),
              const SizedBox(height: 16),

              // 5. Section 4: Device Security & Backup
              _buildSection(
                number: '04',
                title: 'User Device Responsibility',
                icon: Icons.phonelink_lock_rounded,
                color: AppColors.primaryPink,
                content:
                    'Because PennyPal prioritizes local-first storage, you are responsible for maintaining the physical and digital security of your device. We recommend enabling device passcode or biometric authentication to prevent unauthorized local access to your budget records.',
              ),
              const SizedBox(height: 16),

              // 6. Section 5: Modifications to Service
              _buildSection(
                number: '05',
                title: 'Service Updates & Continuous Improvement',
                icon: Icons.update_rounded,
                color: AppColors.purple,
                content:
                    'We continuously update PennyPal to add new student features, improve performance, and patch security vulnerabilities. We reserve the right to modify these terms with reasonable prior notice provided in app release notes.',
              ),
              const SizedBox(height: 24),

              // 7. Interactive Agreement Acknowledgment
              _buildAgreementCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.verified_user_rounded,
                  color: AppColors.primaryBlue, size: 22),
              SizedBox(width: 8),
              Text(
                'Key Takeaways (In Plain English)',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _takeawayItem('Your financial records remain strictly on your device.'),
          _takeawayItem('PennyPal is 100% free for students with zero hidden charges.'),
          _takeawayItem('Calculations and AI tips are budgeting guides, not legal advice.'),
        ],
      ),
    );
  }

  Widget _takeawayItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.check_circle_rounded,
                color: AppColors.successGreen, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _agreed,
            activeColor: AppColors.primaryPink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (val) {
              setState(() => _agreed = val ?? true);
            },
          ),
          const Expanded(
            child: Text(
              'I understand and accept the PennyPal terms of service and student privacy guidelines.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
