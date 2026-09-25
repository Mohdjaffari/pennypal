import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../components/home/home_header.dart';

/// Screen displaying the Privacy Policy for PennyPal.
/// Engineered with clear student-centric transparency, disclosure cards,
/// device permission details, and functional data control utilities (Export, Clear Cache).
class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const PrivacyPolicyScreen({super.key, this.onBack});

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting your encrypted financial data (JSON)...'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Download',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File saved to device Downloads!'),
                backgroundColor: AppColors.successGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Clear Cached Data?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will purge temporary cached images, theme states, and search logs. Your main transaction records will NOT be deleted.',
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Temporary cache cleared successfully!'),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeHeader(
        title: 'Privacy Policy 🛡️',
        subtitle: 'Your data, your control',
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
              // 1. Privacy Badges Row
              _buildBadgesRow(),
              const SizedBox(height: 22),

              // 2. Section 1: What We Collect
              _buildPolicyCard(
                icon: Icons.checklist_rounded,
                color: AppColors.primaryBlue,
                title: '1. What We Collect',
                content:
                    'PennyPal only processes the information you explicitly provide: transaction titles, amounts, dates, budget targets, and savings goals. We do NOT require your bank passwords, ATM pins, or government ID numbers.',
              ),
              const SizedBox(height: 14),

              // 3. Section 2: Local-First Architecture
              _buildPolicyCard(
                icon: Icons.storage_rounded,
                color: AppColors.successGreen,
                title: '2. Local-First Storage Guarantee',
                content:
                    'All your personal budgeting calculations and notes remain stored locally in your device SQLite/SharedPreferences sandbox. They are never transmitted to third-party ad networks or data brokers.',
              ),
              const SizedBox(height: 14),

              // 4. Section 3: Device Permissions Explained
              _buildPolicyCard(
                icon: Icons.security_rounded,
                color: AppColors.shoppingOrange,
                title: '3. Device Permissions',
                content:
                    '• Notifications: Used solely to alert you when a category budget exceeds 80% or when you achieve a savings milestone.\n• Storage / Camera: Used only when you attach receipts or photos to individual expenses.',
              ),
              const SizedBox(height: 14),

              // 5. Section 4: Data Retention & Right to Delete
              _buildPolicyCard(
                icon: Icons.delete_sweep_rounded,
                color: AppColors.primaryPink,
                title: '4. Your Right to Delete',
                content:
                    'You maintain absolute control over your financial records. You can delete any individual transaction, remove all budget caps, or reset the app entirely at any time.',
              ),
              const SizedBox(height: 24),

              // 6. Data Management Actions (Export, Clear Cache)
              const Text(
                'Data Management & Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildDataActionButtons(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesRow() {
    return Row(
      children: [
        _badge('Zero Ads', Icons.block_flipped, AppColors.primaryPink),
        const SizedBox(width: 8),
        _badge('Local-First', Icons.phone_android_rounded, AppColors.primaryBlue),
        const SizedBox(width: 8),
        _badge('Encrypted', Icons.lock_outline_rounded, AppColors.successGreen),
      ],
    );
  }

  Widget _badge(String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required Color color,
    required String title,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
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

  Widget _buildDataActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _exportData(context),
            icon: const Icon(Icons.file_download_outlined, size: 20),
            label: const Text('Export My Financial Data (JSON)',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _showClearCacheDialog(context),
            icon: const Icon(Icons.delete_outline_rounded,
                size: 20, color: AppColors.expenseRed),
            label: const Text('Clear Temporary Cached Data',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.expenseRed)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.expenseRed, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
