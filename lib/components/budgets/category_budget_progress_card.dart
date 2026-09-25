import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/budget_model.dart';

/// Individual progress card for a category budget limit,
/// matching Screen 4 ("Budgets") in the PennyPal design system.
class CategoryBudgetProgressCard extends StatelessWidget {
  final CategoryBudgetModel budget;
  final VoidCallback? onTap;

  const CategoryBudgetProgressCard({
    super.key,
    required this.budget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Icon Squircle
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: budget.backgroundColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      budget.icon,
                      color: budget.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Category Name & Ratio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          budget.formattedRatio,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Percentage Text
                  Text(
                    '${budget.usagePercentage}%',
                    style: TextStyle(
                      color: budget.isOverBudget
                          ? AppColors.expenseRed
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Bar Track
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: budget.progressRatio,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    budget.isOverBudget ? AppColors.expenseRed : budget.color,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
