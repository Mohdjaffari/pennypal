import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/budget_model.dart';
import '../../components/budgets/category_picker_sheet.dart';
import '../../components/home/home_header.dart';

import '../../core/repository/pennypal_repository.dart';

/// Screen allowing users to configure a new Category Budget Limit or edit an existing one.
/// Rebuilt with clean, human-readable architecture, real category selector,
/// live monthly expense calculation for the chosen category, and form validation.
class AddBudgetScreen extends StatefulWidget {
  final ValueChanged<CategoryBudgetModel>? onBudgetSaved;
  final CategoryBudgetModel? initialBudget;

  const AddBudgetScreen({
    super.key,
    this.onBudgetSaved,
    this.initialBudget,
  });

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  Map<String, dynamic> _selectedCategory =
      CategoryPickerSheet.budgetCategories.first;
  String _selectedPeriod = 'Monthly';
  bool _enableAlerts = true;

  double _currentMonthSpending = 0.0;
  int _currentMonthCount = 0;
  bool _isLoadingSpending = false;

  bool get isEditing => widget.initialBudget != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialBudget != null) {
      final b = widget.initialBudget!;
      _amountController.text = b.limitAmount % 1 == 0
          ? b.limitAmount.toInt().toString()
          : b.limitAmount.toStringAsFixed(2);

      final match = CategoryPickerSheet.budgetCategories.firstWhere(
        (c) => PennyPalRepository.isCategoryMatch(c['name'] as String, b.category),
        orElse: () => {
          'name': b.category,
          'icon': b.icon,
          'color': b.color,
          'bgColor': b.backgroundColor,
        },
      );
      _selectedCategory = match;
    }
    _loadCategorySpending();
  }

  Future<void> _loadCategorySpending() async {
    setState(() => _isLoadingSpending = true);
    final allTx = await PennyPalRepository.instance.getTransactions();
    final now = DateTime.now();
    double sum = 0.0;
    int count = 0;
    final catName = _selectedCategory['name'] as String;

    for (final tx in allTx) {
      if (!tx.isExpense) continue;
      final d = tx.parsedDate;
      if (d.year == now.year && d.month == now.month) {
        if (PennyPalRepository.isCategoryMatch(catName, tx.category)) {
          sum += tx.amount;
          count++;
        }
      }
    }
    if (mounted) {
      setState(() {
        _currentMonthSpending = sum;
        _currentMonthCount = count;
        _isLoadingSpending = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _chooseCategory() async {
    final chosen = await CategoryPickerSheet.show(
      context,
      _selectedCategory['name'] as String,
    );
    if (chosen != null) {
      setState(() => _selectedCategory = chosen);
      _loadCategorySpending();
    }
  }

  void _choosePeriod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Period',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: 12),
              ...['Weekly', 'Monthly', 'Yearly'].map(
                (p) => ListTile(
                  title: Text(
                    p,
                    style: TextStyle(
                      color: AppColors.textPrimaryOf(context),
                      fontWeight: _selectedPeriod == p ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: _selectedPeriod == p
                      ? const Icon(Icons.check, color: AppColors.primaryBlue)
                      : null,
                  onTap: () {
                    setState(() => _selectedPeriod = p);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final limit = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final budgetToSave = CategoryBudgetModel(
      id: widget.initialBudget?.id ?? 'b_${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory['name'] as String,
      spentAmount: widget.initialBudget?.spentAmount ?? _currentMonthSpending,
      limitAmount: limit,
      icon: _selectedCategory['icon'] as IconData,
      color: _selectedCategory['color'] as Color,
      backgroundColor: _selectedCategory['bgColor'] as Color,
    );

    await PennyPalRepository.instance.saveBudget(budgetToSave);
    widget.onBudgetSaved?.call(budgetToSave);
    if (mounted) {
      Navigator.of(context).pop(budgetToSave);
    }
  }

  Widget _buildCategorySpendInsight() {
    final catName = _selectedCategory['name'] as String;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights_rounded, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isLoadingSpending
                  ? 'Calculating current spending...'
                  : _currentMonthCount > 0
                      ? 'You spent Rs. ${_currentMonthSpending.toInt()} across $_currentMonthCount expenses in $catName this month.'
                      : 'No expenses recorded in $catName this month yet.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: HomeHeader(
        title: isEditing ? 'Edit Budget Limit 🎯' : 'Set New Budget 🎯',
        subtitle: isEditing
            ? 'Adjust monthly spending limit for ${_selectedCategory['name']}'
            : 'Define monthly limit & alert threshold',
        isBackNavigation: true,
        onMenuPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Budget Amount Input
                _buildFieldLabel('Budget Limit'),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: _inputDecoration(
                    hint: '0',
                    prefixText: 'Rs. ',
                    prefixIcon: Icons.account_balance_wallet_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a budget limit';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                // 2. Category Selector Dropdown Field
                _buildFieldLabel('Budget Category'),
                InkWell(
                  onTap: _chooseCategory,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedCategory['name']),
                      initialValue: _selectedCategory['name'] as String,
                      style: TextStyle(
                        color: AppColors.textPrimaryOf(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Select Category',
                        prefixIcon: _selectedCategory['icon'] as IconData,
                        suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondaryOf(context)),
                      ),
                    ),
                  ),
                ),
                _buildCategorySpendInsight(),
                const SizedBox(height: 22),

                // 3. Time Period Dropdown Field
                _buildFieldLabel('Time Period'),
                InkWell(
                  onTap: _choosePeriod,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedPeriod),
                      initialValue: _selectedPeriod,
                      style: TextStyle(
                        color: AppColors.textPrimaryOf(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Period',
                        prefixIcon: Icons.calendar_view_month_outlined,
                        suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondaryOf(context)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Spending Alerts Toggle Card
                _buildAlertToggle(),
                const SizedBox(height: 36),

                // 5. Save Button
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryOf(context),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkTextSecondary
            : AppColors.textMuted,
        fontSize: 14,
      ),
      filled: true,
      fillColor: AppColors.surfaceOf(context),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: AppColors.primaryPink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.textSecondaryOf(context), size: 20)
          : null,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.borderOf(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.borderOf(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
      ),
    );
  }

  Widget _buildAlertToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryPink.withValues(alpha: 0.2)
                      : AppColors.primaryPinkLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primaryPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Alerts',
                    style: TextStyle(
                      color: AppColors.textPrimaryOf(context),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Warn me at 80% usage',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _enableAlerts,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primaryPink,
            onChanged: (val) => setState(() => _enableAlerts = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
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
      child: ElevatedButton(
        onPressed: _submitBudget,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          isEditing ? 'Save Changes' : 'Set Budget',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
