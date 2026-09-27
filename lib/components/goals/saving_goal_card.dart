import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/saving_goal_model.dart';

/// Reusable card displaying an individual savings goal with its progress bar,
/// replicating the Savings Goals screen in the PennyPal design system.
class SavingGoalCard extends StatelessWidget {
  final SavingGoalModel goal;
  final VoidCallback? onTap;
  final VoidCallback? onAddMoney;

  const SavingGoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderOf(context), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon squircle + Goal Title & Progress Numbers
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Squircle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? goal.color.withValues(alpha: 0.2)
                          : goal.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      goal.icon,
                      color: goal.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Goal Title & Saved Ratio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: TextStyle(
                            color: AppColors.textPrimaryOf(context),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          goal.formattedProgressOverview,
                          style: TextStyle(
                            color: AppColors.textSecondaryOf(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Percentage Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.color.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${goal.progressPercentage}%',
                      style: TextStyle(
                        color: goal.color,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Bar Track
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: goal.progressRatio,
                    backgroundColor: AppColors.surfaceMutedOf(context),
                    valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Bottom Info: Monthly target & Target Date & Add Money button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (goal.monthlyContribution > 0)
                        Text(
                          goal.formattedMonthlyContribution,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      Text(
                        'Target: ${goal.targetDate}',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (onAddMoney != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onAddMoney,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: goal.color.withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: goal.color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, size: 14, color: goal.color),
                              const SizedBox(width: 4),
                              Text(
                                'Add Money',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: goal.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
