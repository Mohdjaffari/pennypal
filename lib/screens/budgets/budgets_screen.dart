import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/budget_model.dart';
import '../../components/budgets/budget_donut_chart.dart';
import '../../components/budgets/category_budget_progress_card.dart';
import '../../components/home/home_header.dart';
import 'add_budget_screen.dart';

/// Screen displaying the comprehensive "Budgets & Limits" view in PennyPal.
/// Engineered with executive financial metrics, donut progress visualizer,
/// multi-filter category caps, and an integrated budget creation flow.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  late List<CategoryBudgetModel> _budgets;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Near Limit', 'Healthy'];

  @override
  void initState() {
    super.initState();
    _budgets = List.from(CategoryBudgetModel.defaultBudgets);
  }

  double get _totalSpent =>
      _budgets.fold(0.0, (sum, b) => sum + b.spentAmount);

  double get _totalLimit =>
      _budgets.fold(0.0, (sum, b) => sum + b.limitAmount);

  double get _totalRemaining =>
      (_totalLimit - _totalSpent).clamp(0.0, double.infinity);

  double get _overallUsagePercentage =>
      _totalLimit > 0 ? (_totalSpent / _totalLimit * 100) : 0.0;

  double get _dailySafeSpend {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);
    return _totalRemaining / daysLeft;
  }

  List<CategoryBudgetModel> get _filteredBudgets {
    if (_selectedFilter == 'Near Limit') {
      return _budgets.where((b) => b.usagePercentage >= 80).toList();
    }
    if (_selectedFilter == 'Healthy') {
      return _budgets.where((b) => b.usagePercentage < 80).toList();
    }
    return _budgets;
  }

  void _openAddBudgetScreen() async {
    final newBudget = await Navigator.of(context).push<CategoryBudgetModel>(
      MaterialPageRoute(
        builder: (context) => AddBudgetScreen(
          onBudgetSaved: (created) {
            setState(() {
              _budgets.add(created);
            });
          },
        ),
      ),
    );

    if (newBudget != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget created for ${newBudget.category}!'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showBudgetDetails(CategoryBudgetModel budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: budget.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(budget.icon, color: budget.color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.category,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            budget.isOverBudget
                                ? 'Exceeded Monthly Cap'
                                : 'Monthly Spending Limit',
                            style: TextStyle(
                              fontSize: 13,
                              color: budget.isOverBudget
                                  ? AppColors.expenseRed
                                  : AppColors.textSecondary,
                              fontWeight: budget.isOverBudget
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: budget.isOverBudget
                            ? AppColors.expenseRed.withValues(alpha: 0.1)
                            : budget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${budget.usagePercentage}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: budget.isOverBudget
                              ? AppColors.expenseRed
                              : budget.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Linear Visual Progress Track
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: budget.progressRatio,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budget.isOverBudget ? AppColors.expenseRed : budget.color,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 20),

                // Numeric Metrics Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _detailRow('Total Spent',
                          'Rs. ${budget.spentAmount.toInt()}',
                          isBold: true),
                      const SizedBox(height: 12),
                      _detailRow(
                          'Total Cap', 'Rs. ${budget.limitAmount.toInt()}'),
                      const SizedBox(height: 12),
                      _detailRow(
                        budget.isOverBudget ? 'Over Budget By' : 'Remaining',
                        budget.isOverBudget
                            ? 'Rs. ${(budget.spentAmount - budget.limitAmount).toInt()}'
                            : 'Rs. ${(budget.limitAmount - budget.spentAmount).toInt()}',
                        valueColor: budget.isOverBudget
                            ? AppColors.expenseRed
                            : AppColors.successGreen,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions: Delete or Dismiss
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _budgets.removeWhere((b) => b.id == budget.id);
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Budget for ${budget.category} removed'),
                              backgroundColor: AppColors.expenseRed,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.expenseRed),
                        label: const Text(
                          'Delete Budget',
                          style: TextStyle(
                            color: AppColors.expenseRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.expenseRed, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14.5,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBudgets;

    return Scaffold(
      backgroundColor: AppColors.background,

      // 1. Unified Sticky App Bar matching Home, Expenses, and Goals
      appBar: HomeHeader(
        title: 'Budgets & Limits 📊',
        subtitle: 'Monthly caps & spending health',
        isBackNavigation: true,
        onMenuPressed: () => Navigator.of(context).maybePop(),
        actions: [
          HomeHeader.circularButton(
            icon: Icons.add_rounded,
            iconColor: AppColors.primaryPink,
            onTap: _openAddBudgetScreen,
            tooltip: 'Set Budget',
          ),
        ],
      ),

      // 2. Scrollable Body + Sticky Bottom CTA
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Hero Overview Card with Donut & Financial Pulse
                    _buildHeroOverviewCard(),
                    const SizedBox(height: 24),

                    // B. Category Budgets Header with Live Count
                    _buildCategoryHeader(),
                    const SizedBox(height: 12),

                    // C. Filter Chips (All, Near Limit, Healthy)
                    _buildFilterChips(),
                    const SizedBox(height: 16),

                    // D. List of Category Progress Cards or Empty State
                    if (filtered.isEmpty) ...[
                      _buildEmptyState(),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return CategoryBudgetProgressCard(
                            budget: item,
                            onTap: () => _showBudgetDetails(item),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // E. Sticky Bottom CTA: "Set New Budget"
            _buildBottomCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroOverviewCard() {
    final isOver = _totalSpent > _totalLimit;
    final isWarning = !isOver && _overallUsagePercentage >= 80;

    final badgeBg = isOver
        ? const Color(0xFFFFECEE)
        : isWarning
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFE8FDF5);

    final badgeColor = isOver
        ? AppColors.expenseRed
        : isWarning
            ? AppColors.shoppingOrange
            : AppColors.successGreen;

    final badgeText = isOver
        ? 'Over Budget 🚨'
        : isWarning
            ? 'Watch Out ⚠️'
            : 'On Track 🟢';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header with title & health badge
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Monthly Consumption',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Overall Budget Health',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Donut Ring Chart Visualizer
          BudgetDonutChart(
            totalSpent: _totalSpent,
            totalLimit: _totalLimit,
            monthTitle: 'This Month',
          ),

          // 3-Metric Quick Status Pill Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _metricPill(
                    label: 'Spent',
                    value: 'Rs. ${_totalSpent.toInt()}',
                    dotColor: AppColors.primaryPink,
                  ),
                  Container(
                      width: 1,
                      height: 28,
                      color: AppColors.border.withValues(alpha: 0.8)),
                  _metricPill(
                    label: 'Remaining',
                    value: 'Rs. ${_totalRemaining.toInt()}',
                    dotColor: AppColors.successGreen,
                  ),
                  Container(
                      width: 1,
                      height: 28,
                      color: AppColors.border.withValues(alpha: 0.8)),
                  _metricPill(
                    label: 'Safe/Day',
                    value: 'Rs. ${_dailySafeSpend.toInt()}',
                    dotColor: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricPill({
    required String label,
    required String value,
    required Color dotColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Category Budgets',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryBlueLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_filteredBudgets.length} Categories',
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryBlue : AppColors.border,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlueLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.done_all_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Budgets Match Filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All your category spending limits are within safe thresholds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppColors.pinkGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _openAddBudgetScreen,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: const Text(
            'Set New Budget Limit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
