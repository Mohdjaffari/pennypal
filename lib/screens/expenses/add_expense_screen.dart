import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../core/repository/pennypal_repository.dart';
import '../budgets/add_budget_screen.dart';
import '../../components/expenses/expense_category_picker_sheet.dart';
import '../../components/expenses/payment_method_picker_sheet.dart';
import '../../components/expenses/receipt_image_viewer.dart';
import '../../core/localization/language_service.dart';
import 'dart:async';

/// Screen 2 from PennyPal: "Add / Edit Expense"
/// Engineered with clean component-based architecture, interactive category & payment method selectors,
/// date picker with dark-mode contrast, real camera/gallery receipt image upload & zoom preview,
/// live budget limit monitoring, and comprehensive multilingual translation.
class AddExpenseScreen extends StatefulWidget {
  final ValueChanged<TransactionModel>? onExpenseSaved;
  final TransactionModel? initialExpense;
  final String? initialCategory;

  const AddExpenseScreen({
    super.key,
    this.onExpenseSaved,
    this.initialExpense,
    this.initialCategory,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  ExpenseCategoryItem _selectedCategory =
      ExpenseCategoryPickerSheet.categories.first;
  PaymentMethodItem _selectedPaymentMethod =
      PaymentMethodPickerSheet.methods.first;
  DateTime _selectedDate = DateTime.now();

  bool _hasReceiptAttached = false;
  String? _receiptPath;
  String? _receiptName;

  List<CategoryBudgetModel> _budgets = [];
  StreamSubscription<List<CategoryBudgetModel>>? _budgetSub;

  bool get isEditing => widget.initialExpense != null;

  CategoryBudgetModel? get _matchedBudget {
    for (final b in _budgets) {
      if (PennyPalRepository.isCategoryMatch(b.category, _selectedCategory.name)) {
        return b;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialCategory != null) {
      final matchedCat = ExpenseCategoryPickerSheet.categories.firstWhere(
        (c) => PennyPalRepository.isCategoryMatch(c.name, widget.initialCategory!),
        orElse: () => ExpenseCategoryPickerSheet.categories.first,
      );
      _selectedCategory = matchedCat;
    }

    if (widget.initialExpense != null) {
      final exp = widget.initialExpense!;
      _amountController.text = exp.amount.toInt().toString();
      _noteController.text = exp.note.isNotEmpty ? exp.note : exp.title;
      _hasReceiptAttached = exp.hasReceipt;
      _receiptPath = exp.receiptPath;
      if (_hasReceiptAttached && (_receiptPath != null && _receiptPath!.isNotEmpty)) {
        _receiptName = 'receipt_${exp.id.replaceAll('exp_', '').substring(0, 6.clamp(0, exp.id.length))}.jpg';
      }

      final matchedCat = ExpenseCategoryPickerSheet.categories.firstWhere(
        (c) => c.name.toLowerCase() == exp.category.toLowerCase(),
        orElse: () => ExpenseCategoryPickerSheet.categories.first,
      );
      _selectedCategory = matchedCat;

      final matchedPay = PaymentMethodPickerSheet.methods.firstWhere(
        (m) => m.name.toLowerCase() == exp.paymentMethod.toLowerCase(),
        orElse: () => PaymentMethodPickerSheet.methods.first,
      );
      _selectedPaymentMethod = matchedPay;
    }

    _loadBudgets();
    _budgetSub = PennyPalRepository.instance.budgetsStream.listen((list) {
      if (mounted) {
        setState(() => _budgets = list);
      }
    });
    _amountController.addListener(_onAmountChanged);
  }

  Future<void> _loadBudgets() async {
    final list = await PennyPalRepository.instance.getBudgets();
    if (mounted) {
      setState(() => _budgets = list);
    }
  }

  void _onAmountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _budgetSub?.cancel();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _chooseCategory() async {
    final chosen = await ExpenseCategoryPickerSheet.show(
      context,
      _selectedCategory.name,
    );
    if (chosen != null) {
      setState(() => _selectedCategory = chosen);
    }
  }

  Future<void> _choosePaymentMethod() async {
    final chosen = await PaymentMethodPickerSheet.show(
      context,
      _selectedPaymentMethod.name,
    );
    if (chosen != null) {
      setState(() => _selectedPaymentMethod = chosen);
    }
  }

  Future<void> _chooseDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryPink,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primaryPink,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Opens bottom sheet offering Camera or Gallery image selection
  Future<void> _showReceiptPickerOptions() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.surfaceOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
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
              Text(
                _hasReceiptAttached ? context.tr('change_receipt') : context.tr('add_receipt'),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
                ),
                title: Text(
                  context.tr('take_photo'),
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Capture with device camera', style: TextStyle(color: textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryPink),
                ),
                title: Text(
                  context.tr('choose_gallery'),
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Select image from photo gallery', style: TextStyle(color: textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickReceipt(ImageSource.gallery);
                },
              ),
              if (_hasReceiptAttached) ...[
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.expenseRed.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed),
                  ),
                  title: Text(
                    context.tr('remove_receipt'),
                    style: const TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeReceipt();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickReceipt(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final dataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        setState(() {
          _hasReceiptAttached = true;
          _receiptPath = dataUri;
          _receiptName = picked.name.isNotEmpty ? picked.name : 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(context.tr('receipt_attached')),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access image: $e'),
          backgroundColor: AppColors.expenseRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeReceipt() {
    setState(() {
      _hasReceiptAttached = false;
      _receiptPath = null;
      _receiptName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('remove_receipt')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitExpense() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final note = _noteController.text.trim();

    final expense = TransactionModel(
      id: widget.initialExpense?.id ?? 'exp_${DateTime.now().millisecondsSinceEpoch}',
      title: note.isNotEmpty ? note : _selectedCategory.name,
      date: _formatDate(_selectedDate),
      amount: amount,
      icon: _selectedCategory.icon,
      color: _selectedCategory.color,
      backgroundColor: _selectedCategory.backgroundColor,
      category: _selectedCategory.name,
      isExpense: true,
      paymentMethod: _selectedPaymentMethod.name,
      hasReceipt: _hasReceiptAttached,
      receiptPath: _receiptPath,
      note: note,
    );

    widget.onExpenseSaved?.call(expense);
    Navigator.of(context).pop(expense);
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOf(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? context.tr('edit_expense') : context.tr('add_expense'),
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
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
                // 1. Amount Field
                _buildFieldLabel(context.tr('amount')),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: textPrimary,
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
                      return 'Please enter an expense amount';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 2. Category Selector Dropdown Field
                _buildFieldLabel(context.tr('category')),
                InkWell(
                  onTap: _chooseCategory,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedCategory.name),
                      initialValue: _selectedCategory.name,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Select Category',
                        prefixIcon: _selectedCategory.icon,
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildLiveBudgetInsightCard(),
                const SizedBox(height: 20),

                // 3. Date Dropdown Field
                _buildFieldLabel(context.tr('date')),
                InkWell(
                  onTap: _chooseDate,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedDate),
                      initialValue: _formatDate(_selectedDate),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Date',
                        prefixIcon: Icons.calendar_today_outlined,
                        suffixIcon: Icon(
                          Icons.edit_calendar_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Payment Method Dropdown Field
                _buildFieldLabel(context.tr('payment_method')),
                InkWell(
                  onTap: _choosePaymentMethod,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedPaymentMethod.name),
                      initialValue: _selectedPaymentMethod.name,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Select Method',
                        prefixIcon: _selectedPaymentMethod.icon,
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Note (Optional) Multi-line Field
                _buildFieldLabel(context.tr('note_optional')),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.textMuted,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceOf(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
                      borderSide: const BorderSide(
                        color: AppColors.primaryPink,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Professional Receipt Attachment Section
                _buildAddReceiptSection(),
                const SizedBox(height: 32),

                // 7. Save Expense CTA Button
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBudgetInsightCard() {
    final budget = _matchedBudget;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (budget == null) {
      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondaryOf(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No budget limit set for ${_selectedCategory.name}.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final created = await Navigator.of(context).push<CategoryBudgetModel>(
                  MaterialPageRoute(
                    builder: (_) => const AddBudgetScreen(),
                  ),
                );
                if (created != null) {
                  _loadBudgets();
                }
              },
              child: const Text(
                'Set Limit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPink,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final double previousAmount = (isEditing && PennyPalRepository.isCategoryMatch(budget.category, widget.initialExpense!.category))
        ? widget.initialExpense!.amount
        : 0.0;
    final double projectedSpent = (budget.spentAmount - previousAmount + enteredAmount).clamp(0.0, double.infinity);
    final double projectedRatio = budget.limitAmount > 0 ? (projectedSpent / budget.limitAmount) : 0.0;
    final int projectedPercentage = (projectedRatio * 100).round();
    final bool willExceed = projectedSpent > budget.limitAmount;
    final bool isNearLimit = !willExceed && projectedPercentage >= 80;

    final Color statusColor = willExceed
        ? AppColors.expenseRed
        : isNearLimit
            ? AppColors.shoppingOrange
            : AppColors.successGreen;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    willExceed
                        ? Icons.warning_amber_rounded
                        : isNearLimit
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                    size: 18,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${budget.category} Budget',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$projectedPercentage%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: projectedRatio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            willExceed
                ? '⚠️ This expense will exceed your monthly limit by Rs. ${(projectedSpent - budget.limitAmount).toInt()}!'
                : isNearLimit
                    ? '⚡ Caution: Will consume $projectedPercentage% of monthly limit (Rs. ${(budget.limitAmount - projectedSpent).toInt()} remaining).'
                    : '✓ Within budget: Rs. ${(budget.limitAmount - projectedSpent).toInt()} will remain after this expense.',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
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

  Widget _buildAddReceiptSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    if (_hasReceiptAttached && _receiptPath != null && _receiptPath!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.35 : 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Receipt Thumbnail with zoom click
            GestureDetector(
              onTap: () => ReceiptImageViewer.showPreview(
                context,
                _receiptPath!,
                title: _receiptName ?? 'Receipt Preview',
              ),
              child: Stack(
                children: [
                  ReceiptImageViewer(
                    receiptPath: _receiptPath!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Filename and View action
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _receiptName ?? context.tr('receipt_attached'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () => ReceiptImageViewer.showPreview(
                      context,
                      _receiptPath!,
                      title: _receiptName ?? 'Receipt Preview',
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, size: 13, color: AppColors.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('view_receipt'),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Change & Remove actions
            IconButton(
              icon: Icon(Icons.edit_outlined, color: textSecondary, size: 20),
              tooltip: context.tr('change_receipt'),
              onPressed: _showReceiptPickerOptions,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed, size: 20),
              tooltip: context.tr('remove_receipt'),
              onPressed: _removeReceipt,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _showReceiptPickerOptions,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMutedOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderOf(context),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: AppColors.primaryBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr('add_receipt'),
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
        onPressed: _submitExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          isEditing ? context.tr('update_expense') : context.tr('save_expense'),
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
