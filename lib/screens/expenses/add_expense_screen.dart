import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../components/expenses/expense_category_picker_sheet.dart';
import '../../components/expenses/payment_method_picker_sheet.dart';

/// Screen 2 from PennyPal design board: "Add Expense"
/// Rebuilt with clean, human-readable component-based architecture,
/// interactive category & payment method selectors, date picker, receipt attachment,
/// and form validation.
class AddExpenseScreen extends StatefulWidget {
  final ValueChanged<TransactionModel>? onExpenseSaved;

  const AddExpenseScreen({
    super.key,
    this.onExpenseSaved,
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

  @override
  void dispose() {
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
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

  void _toggleReceipt() {
    setState(() {
      _hasReceiptAttached = !_hasReceiptAttached;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _hasReceiptAttached
              ? 'Receipt attached successfully!'
              : 'Receipt removed',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitExpense() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final note = _noteController.text.trim();

    final newExpense = TransactionModel(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
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
      note: note,
    );

    widget.onExpenseSaved?.call(newExpense);
    Navigator.of(context).pop(newExpense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                _buildFieldLabel('Amount'),
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
                _buildFieldLabel('Category'),
                InkWell(
                  onTap: _chooseCategory,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedCategory.name),
                      initialValue: _selectedCategory.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Select Category',
                        prefixIcon: _selectedCategory.icon,
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Date Dropdown Field
                _buildFieldLabel('Date'),
                InkWell(
                  onTap: _chooseDate,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedDate),
                      initialValue: _formatDate(_selectedDate),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Date',
                        prefixIcon: Icons.calendar_today_outlined,
                        suffixIcon: const Icon(
                          Icons.edit_calendar_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Payment Method Dropdown Field
                _buildFieldLabel('Payment Method'),
                InkWell(
                  onTap: _choosePaymentMethod,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedPaymentMethod.name),
                      initialValue: _selectedPaymentMethod.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Select Method',
                        prefixIcon: _selectedPaymentMethod.icon,
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Note (Optional) Multi-line Field
                _buildFieldLabel('Note (Optional)'),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
                      borderSide: const BorderSide(
                        color: AppColors.primaryPink,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Add Receipt Button & Attached Preview Chip
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

  Widget _buildAddReceiptSection() {
    if (_hasReceiptAttached) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryBlueLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_rounded, color: AppColors.primaryBlue, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'receipt_scan_01.jpg (Attached)',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.primaryBlue, size: 18),
              onPressed: _toggleReceipt,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    return TextButton.icon(
      onPressed: _toggleReceipt,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primaryBlueLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.camera_alt_rounded,
            color: AppColors.primaryBlue, size: 15),
      ),
      label: const Text(
        'Add Receipt (Optional)',
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        child: const Text(
          'Save Expense',
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
