import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/budget_model.dart';
import '../../components/budgets/category_picker_sheet.dart';
import '../../components/home/home_header.dart';

/// Screen allowing users to configure a new Category Budget Limit.
/// Rebuilt with clean, human-readable architecture, real category selector,
/// period choices, and form validation.
class AddBudgetScreen extends StatefulWidget {
  final ValueChanged<CategoryBudgetModel>? onBudgetSaved;

  const AddBudgetScreen({super.key, this.onBudgetSaved});

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
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Period',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...['Weekly', 'Monthly', 'Yearly'].map(
                (p) => ListTile(
                  title: Text(p),
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

  void _submitBudget() {
    if (!_formKey.currentState!.validate()) return;

    final limit = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final newBudget = CategoryBudgetModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory['name'] as String,
      spentAmount: 0.0,
      limitAmount: limit,
      icon: _selectedCategory['icon'] as IconData,
      color: _selectedCategory['color'] as Color,
      backgroundColor: _selectedCategory['bgColor'] as Color,
    );

    widget.onBudgetSaved?.call(newBudget);
    Navigator.of(context).pop(newBudget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeHeader(
        title: 'Set New Budget 🎯',
        subtitle: 'Define monthly limit & alert threshold',
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Select Category',
                        prefixIcon: _selectedCategory['icon'] as IconData,
                        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Period',
                        prefixIcon: Icons.calendar_view_month_outlined,
                        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
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
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
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
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.surface,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: AppColors.primaryPink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
          : null,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
      ),
    );
  }

  Widget _buildAlertToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPinkLight,
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
                children: const [
                  Text(
                    'Spending Alerts',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
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
        child: const Text(
          'Set Budget',
          style: TextStyle(
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
