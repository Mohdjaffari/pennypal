import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Top profile card with user avatar, name, student badge, and financial summary chips.
class ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final String userRole;
  final String balance;
  final String savings;
  final VoidCallback onEdit;

  const ProfileHeaderCard({
    super.key,
    required this.userName,
    required this.userRole,
    this.balance = 'Rs. 12,450',
    this.savings = 'Rs. 3,200',
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar Stack with Verified Badge & Edit button
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'J',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // User Name
        Text(
          userName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),

        // Student Role Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryBlueLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            userRole,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Summary Chips Row (Balance & Saved)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryChip(
                  label: 'Total Balance',
                  value: balance,
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryChip(
                  label: 'Total Savings',
                  value: savings,
                  icon: Icons.savings_rounded,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
