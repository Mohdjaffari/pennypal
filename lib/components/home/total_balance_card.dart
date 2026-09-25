import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'painters/sparkline_painter.dart';

/// Hero Card for displaying Total Balance.
/// Supports both:
/// 1. [Design Style]: Clean elevated white card matching the PennyPal Figma mockup.
/// 2. [Graph Style]: Vibrant blue gradient card with curved sparkline trend.
class TotalBalanceCard extends StatelessWidget {
  final String balance;
  final String trendPercentage;
  final bool isTrendPositive;
  final bool useSparklineStyle;
  final VoidCallback? onTap;

  const TotalBalanceCard({
    super.key,
    this.balance = 'Rs. 12,450',
    this.trendPercentage = '+12% this month',
    this.isTrendPositive = true,
    this.useSparklineStyle = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return useSparklineStyle
        ? _buildSparklineCard(context)
        : _buildPennyPalDesignCard(context);
  }

  /// 1. PennyPal Figma Design: Crisp, elevated white card with wallet squircle and green trend badge
  Widget _buildPennyPalDesignCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Blue Wallet Squircle
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Total Balance Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  balance,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                // Green trend pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTrendPositive
                        ? AppColors.successGreenLight
                        : AppColors.expenseRedLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: isTrendPositive
                            ? AppColors.successGreen
                            : AppColors.expenseRed,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendPercentage,
                        style: TextStyle(
                          color: isTrendPositive
                              ? AppColors.successGreen
                              : AppColors.expenseRed,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Blue Sparkline Variant with smooth wave painter
  Widget _buildSparklineCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Sparkline Graphic
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 90,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: const CustomPaint(
                painter: SparklinePainter(),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  balance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendPercentage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
