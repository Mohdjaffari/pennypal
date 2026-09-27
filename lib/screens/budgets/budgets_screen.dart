import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/budget_model.dart';
import '../../models/transaction_model.dart';
import '../../components/budgets/budget_donut_chart.dart';
import '../../components/budgets/category_budget_progress_card.dart';
import '../../components/home/home_header.dart';
import 'add_budget_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../../core/repository/pennypal_repository.dart';
import '../../core/auth/auth_service.dart';
import '../../core/localization/language_service.dart';
import 'dart:async';

/// Screen displaying the comprehensive "Budgets & Limits" view in PennyPal.
/// Engineered with executive financial metrics, donut progress visualizer,
/// multi-filter category caps, live transaction collaboration, and an integrated budget creation flow.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  late List<CategoryBudgetModel> _budgets;
  StreamSubscription<List<CategoryBudgetModel>>? _budgetSub;
  StreamSubscription<List<TransactionModel>>? _txSub;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Near Limit', 'Healthy'];

  @override
  void initState() {
    super.initState();
    _budgets = [];
    _loadBudgetsFromDb();
    _budgetSub = PennyPalRepository.instance.budgetsStream.listen((list) {
      if (mounted) {
        setState(() => _budgets = List.from(list));
      }
    });
    _txSub = PennyPalRepository.instance.transactionsStream.listen((_) {
      _loadBudgetsFromDb();
    });
  }

  Future<void> _loadBudgetsFromDb() async {
    final list = await PennyPalRepository.instance.getBudgets();
    if (mounted) {
      setState(() => _budgets = List.from(list));
    }
  }

  @override
  void dispose() {
    _budgetSub?.cancel();
    _txSub?.cancel();
    super.dispose();
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
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in or create an account to set a category budget limit.',
    );
    if (!authorized || !mounted) return;

    final newBudget = await Navigator.of(context).push<CategoryBudgetModel>(
      MaterialPageRoute(
        builder: (context) => AddBudgetScreen(
          onBudgetSaved: (created) async {
            _loadBudgetsFromDb();
          },
        ),
      ),
    );

    if (newBudget != null && mounted) {
      _loadBudgetsFromDb();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr('budget_created')} ${newBudget.category}!'),
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
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day + 1).clamp(1, 31);
    final categoryRemaining = (budget.limitAmount - budget.spentAmount).clamp(0.0, double.infinity);
    final categoryDailySafe = categoryRemaining / daysLeft;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FutureBuilder<List<TransactionModel>>(
        future: PennyPalRepository.instance.getTransactions(),
        builder: (context, snapshot) {
          final allTx = snapshot.data ?? [];
          final categoryExpenses = allTx.where((tx) {
            if (!tx.isExpense) return false;
            final d = tx.parsedDate;
            return d.year == now.year &&
                d.month == now.month &&
                PennyPalRepository.isCategoryMatch(budget.category, tx.category);
          }).toList();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.88,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: AppColors.borderOf(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Category Header
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
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
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryOf(context),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                budget.isOverBudget
                                    ? context.tr('monthly_exceeded')
                                    : context.tr('monthly_limit'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: budget.isOverBudget
                                      ? AppColors.expenseRed
                                      : AppColors.textSecondaryOf(context),
                                  fontWeight: budget.isOverBudget
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: budget.isOverBudget
                                ? AppColors.expenseRed.withValues(alpha: 0.12)
                                : budget.usagePercentage >= 80
                                    ? AppColors.shoppingOrange.withValues(alpha: 0.12)
                                    : AppColors.successGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${budget.usagePercentage}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: budget.isOverBudget
                                  ? AppColors.expenseRed
                                  : budget.usagePercentage >= 80
                                      ? AppColors.shoppingOrange
                                      : AppColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Progress track
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: budget.progressRatio,
                        backgroundColor: AppColors.surfaceMutedOf(context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          budget.isOverBudget
                              ? AppColors.expenseRed
                              : budget.usagePercentage >= 80
                                  ? AppColors.shoppingOrange
                                  : budget.color,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Metrics Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMutedOf(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderOf(context)),
                      ),
                      child: Column(
                        children: [
                          _detailRow(
                            'Spent This Month',
                            'Rs. ${budget.spentAmount.toInt()}',
                            isBold: true,
                          ),
                          const SizedBox(height: 10),
                          _detailRow(
                            'Monthly Limit',
                            'Rs. ${budget.limitAmount.toInt()}',
                          ),
                          const SizedBox(height: 10),
                          _detailRow(
                            budget.isOverBudget ? 'Over Budget By' : 'Remaining Safe Amount',
                            budget.isOverBudget
                                ? 'Rs. ${(budget.spentAmount - budget.limitAmount).toInt()}'
                                : 'Rs. ${(budget.limitAmount - budget.spentAmount).toInt()}',
                            valueColor: budget.isOverBudget
                                ? AppColors.expenseRed
                                : AppColors.successGreen,
                            isBold: true,
                          ),
                          if (!budget.isOverBudget) ...[
                            const SizedBox(height: 10),
                            _detailRow(
                              'Safe Daily Spend ($daysLeft days left)',
                              'Rs. ${categoryDailySafe.toInt()}/day',
                              valueColor: AppColors.primaryBlue,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live Category Expenses Breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Expenses (${categoryExpenses.length})',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryOf(context),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.pop(ctx);
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddExpenseScreen(
                                  initialCategory: budget.category,
                                  onExpenseSaved: (exp) async {
                                    await PennyPalRepository.instance.addTransaction(exp);
                                    _loadBudgetsFromDb();
                                  },
                                ),
                              ),
                            );
                            _loadBudgetsFromDb();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primaryPink),
                                SizedBox(width: 4),
                                Text(
                                  'Add Expense',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (snapshot.connectionState == ConnectionState.waiting) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ] else if (categoryExpenses.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMutedOf(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderOf(context)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 32, color: AppColors.textMuted.withValues(alpha: 0.6)),
                            const SizedBox(height: 8),
                            Text(
                              'No expenses recorded in ${budget.category} this month yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryExpenses.take(5).length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final tx = categoryExpenses[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMutedOf(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderOf(context)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: tx.backgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(tx.icon, color: tx.color, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title.isNotEmpty ? tx.title : tx.category,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.textPrimaryOf(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${tx.date} • ${tx.paymentMethod}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textSecondaryOf(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-Rs. ${tx.amount.toInt()}',
                                  style: const TextStyle(
                                    color: AppColors.expenseRed,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Primary Collaborative Actions: Edit Limit, Delete Budget
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dialogCtx) => AlertDialog(
                                  title: Text('Delete ${budget.category} Budget?'),
                                  content: const Text(
                                    'This will delete this category budget limit. Your recorded expenses will NOT be affected.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await PennyPalRepository.instance.deleteBudget(budget.id);
                                if (ctx.mounted) Navigator.pop(ctx);
                                _loadBudgetsFromDb();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Budget for ${budget.category} deleted.'),
                                    backgroundColor: AppColors.expenseRed,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.expenseRed),
                            label: const Text(
                              'Delete Budget',
                              style: TextStyle(
                                color: AppColors.expenseRed,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.expenseRed, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final updated = await Navigator.of(context).push<CategoryBudgetModel>(
                                MaterialPageRoute(
                                  builder: (_) => AddBudgetScreen(
                                    initialBudget: budget,
                                    onBudgetSaved: (saved) {
                                      _loadBudgetsFromDb();
                                    },
                                  ),
                                ),
                              );
                              if (updated != null) {
                                _loadBudgetsFromDb();
                              }
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                            label: const Text(
                              'Edit Limit',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
          );
        },
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
          style: TextStyle(
            color: AppColors.textSecondaryOf(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimaryOf(context),
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
      backgroundColor: AppColors.backgroundOf(context),

      // 1. Unified Sticky App Bar matching Home, Expenses, and Goals
      appBar: HomeHeader(
        title: context.tr('budgets_title'),
        subtitle: context.tr('budgets_subtitle'),
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
        ? 'Over Budget'
        : isWarning
            ? 'Near Limit'
            : 'On Track';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderOf(context)),
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
                  children: [
                    Text(
                      'Monthly Consumption',
                      style: TextStyle(
                        color: AppColors.textPrimaryOf(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Overall Budget Health',
                      style: TextStyle(
                        color: AppColors.textSecondaryOf(context),
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
                color: AppColors.surfaceMutedOf(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Row(
                children: [
                  _metricPill(
                    context: context,
                    label: 'Spent',
                    value: 'Rs. ${_totalSpent.toInt()}',
                    dotColor: AppColors.primaryPink,
                  ),
                  Container(
                      width: 1,
                      height: 28,
                      color: AppColors.borderOf(context).withValues(alpha: 0.8)),
                  _metricPill(
                    context: context,
                    label: 'Remaining',
                    value: 'Rs. ${_totalRemaining.toInt()}',
                    dotColor: AppColors.successGreen,
                  ),
                  Container(
                      width: 1,
                      height: 28,
                      color: AppColors.borderOf(context).withValues(alpha: 0.8)),
                  _metricPill(
                    context: context,
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
    required BuildContext context,
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
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Category Budgets',
          style: TextStyle(
            color: AppColors.textPrimaryOf(context),
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.primaryBlue.withValues(alpha: 0.2) : AppColors.primaryBlueLight,
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
              backgroundColor: AppColors.surfaceOf(context),
              selectedColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondaryOf(context),
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryBlue : AppColors.borderOf(context),
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
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.done_all_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Budgets Match Filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All your category spending limits are within safe thresholds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondaryOf(context),
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
        color: AppColors.surfaceOf(context),
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
