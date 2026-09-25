import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Segmented filter bar for switching between Weekly, Monthly, and Yearly reports.
class TimePeriodFilter extends StatelessWidget {
  final String selectedPeriod;
  final List<String> periods;
  final ValueChanged<String> onPeriodChanged;

  const TimePeriodFilter({
    super.key,
    required this.selectedPeriod,
    this.periods = const ['Weekly', 'Monthly', 'Yearly'],
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  period,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
