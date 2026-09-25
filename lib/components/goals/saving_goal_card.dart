import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/saving_goal_model.dart';

/// Reusable card displaying an individual savings goal with its progress bar,
/// replicating the Savings Goals screen in the PennyPal design system.
class SavingGoalCard extends StatelessWidget {
  final SavingGoalModel goal;
  final VoidCallback? onTap;

  const SavingGoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
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
                      color: goal.backgroundColor,
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
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          goal.formattedProgressOverview,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
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
                      color: goal.color.withValues(alpha: 0.1),
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
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Bottom Info: Monthly target & Target Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (goal.monthlyContribution > 0)
                    Text(
                      goal.formattedMonthlyContribution,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Text(
                    'Target: ${goal.targetDate}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
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
