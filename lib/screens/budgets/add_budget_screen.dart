import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double _alertThreshold = 0.80; // Manual threshold: 0.50 to 1.0 (50% to 100%)

  double _currentMonthSpending = 0.0;
  int _currentMonthCount = 0;
  bool _isLoadingSpending = false;

  bool get isEditing => widget.initialBudget != null;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    if (widget.initialBudget != null) {
      final b = widget.initialBudget!;
      _amountController.text = b.limitAmount % 1 == 0
          ? b.limitAmount.toInt().toString()
          : b.limitAmount.toStringAsFixed(2);
      _alertThreshold = b.alertThreshold;
      _enableAlerts = b.enableAlert;

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
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {});
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
      alertThreshold: _alertThreshold,
      enableAlert: _enableAlerts,
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
        title: isEditing ? 'Edit Budget Limit' : 'Set New Budget',
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

                // 4. Spending Alerts Manual Threshold Card
                _buildAlertThresholdCard(),
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

  Color _getAlertThresholdColor(double threshold) {
    if (threshold <= 0.65) {
      return AppColors.primaryBlue;
    } else if (threshold <= 0.82) {
      return const Color(0xFFF59E0B); // Amber / Warning
    } else {
      return AppColors.primaryPink; // Urgent / High risk
    }
  }

  Widget _buildPresetChip(int percent, String label) {
    final isSelected = (_alertThreshold * 100).round() == percent;
    final color = _getAlertThresholdColor(percent / 100.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _alertThreshold = percent / 100.0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertThresholdCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final limit = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final thresholdPercent = (_alertThreshold * 100).round();
    final triggerAmount = limit * _alertThreshold;
    final alertColor = _getAlertThresholdColor(_alertThreshold);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _enableAlerts
              ? alertColor.withValues(alpha: 0.35)
              : AppColors.borderOf(context),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _enableAlerts
                ? alertColor.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Notification Icon, Title, and Enable Switch
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _enableAlerts
                      ? alertColor.withValues(alpha: isDark ? 0.22 : 0.12)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _enableAlerts
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                  color: _enableAlerts ? alertColor : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Spending Alert',
                          style: TextStyle(
                            color: AppColors.textPrimaryOf(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_enableAlerts) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: alertColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$thresholdPercent%',
                              style: TextStyle(
                                color: alertColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _enableAlerts
                          ? 'Set warning trigger threshold'
                          : 'Alert notifications paused',
                      style: TextStyle(
                        color: AppColors.textSecondaryOf(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _enableAlerts,
                activeThumbColor: Colors.white,
                activeTrackColor: alertColor,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  setState(() => _enableAlerts = val);
                },
              ),
            ],
          ),

          if (_enableAlerts) ...[
            const SizedBox(height: 18),

            // Dynamic Threshold & Amount Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 16, color: alertColor),
                      const SizedBox(width: 8),
                      Text(
                        'Trigger Alert At:',
                        style: TextStyle(
                          color: AppColors.textSecondaryOf(context),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    limit > 0
                        ? 'Rs. ${triggerAmount.toInt()} ($thresholdPercent%)'
                        : '$thresholdPercent% of limit',
                    style: TextStyle(
                      color: alertColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Custom Interactive Progress Bar / Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: alertColor,
                inactiveTrackColor: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                thumbColor: alertColor,
                overlayColor: alertColor.withValues(alpha: 0.18),
                trackHeight: 6.5,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10,
                  elevation: 3,
                ),
                trackShape: const RoundedRectSliderTrackShape(),
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              child: Slider(
                value: (_alertThreshold * 100).clamp(50.0, 100.0),
                min: 50.0,
                max: 100.0,
                divisions: 10,
                label: '$thresholdPercent%',
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _alertThreshold = val / 100.0);
                },
              ),
            ),

            // Visual Progress Bar Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final totalW = constraints.maxWidth;
                      final currentSpendRatio = limit > 0
                          ? (_currentMonthSpending / limit).clamp(0.0, 1.0)
                          : 0.0;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Base Track
                          Container(
                            height: 8,
                            width: totalW,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Current Month Spend Fill (if any)
                          if (currentSpendRatio > 0)
                            Container(
                              height: 8,
                              width: (totalW * currentSpendRatio).clamp(0.0, totalW),
                              decoration: BoxDecoration(
                                color: currentSpendRatio >= _alertThreshold
                                    ? AppColors.expenseRed
                                    : AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          // Alert Threshold Marker Pin
                          Positioned(
                            left: ((totalW * _alertThreshold) - 5).clamp(0.0, totalW - 10),
                            top: -3,
                            child: Container(
                              width: 10,
                              height: 14,
                              decoration: BoxDecoration(
                                color: alertColor,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: alertColor.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '50% (Early)',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Alert at $thresholdPercent%',
                        style: TextStyle(
                          color: alertColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        '100% (Limit)',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Preset Percentage Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPresetChip(50, '50%'),
                _buildPresetChip(70, '70%'),
                _buildPresetChip(80, '80% (Std)'),
                _buildPresetChip(90, '90%'),
                _buildPresetChip(100, '100%'),
              ],
            ),
            const SizedBox(height: 14),

            // Contextual Guidance Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: isDark ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 15, color: alertColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      limit > 0
                          ? 'PennyPal will alert you when you spend Rs. ${triggerAmount.toInt()} ($thresholdPercent% of your Rs. ${limit.toInt()} budget).'
                          : 'PennyPal will alert you when $thresholdPercent% of this budget is consumed.',
                      style: TextStyle(
                        color: alertColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
