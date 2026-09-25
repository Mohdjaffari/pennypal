import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../components/income/income_source_picker_sheet.dart';

/// Screen 3 from PennyPal design board: "Add Income"
/// Rebuilt with clean, human-readable architecture, real source selector,
/// auto-filled interactive date picker, and form validation.
class AddIncomeScreen extends StatefulWidget {
  final ValueChanged<TransactionModel>? onIncomeSaved;

  const AddIncomeScreen({
    super.key,
    this.onIncomeSaved,
  });

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  IncomeSourceItem _selectedSource = IncomeSourcePickerSheet.sources.first;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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

  Future<void> _chooseSource() async {
    final chosen = await IncomeSourcePickerSheet.show(
      context,
      _selectedSource.name,
    );
    if (chosen != null) {
      setState(() => _selectedSource = chosen);
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

  void _submitIncome() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final description = _descriptionController.text.trim();

    final newIncome = TransactionModel(
      id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
      title: description.isNotEmpty ? description : _selectedSource.name,
      date: _formatDate(_selectedDate),
      amount: amount,
      icon: _selectedSource.icon,
      color: _selectedSource.color,
      backgroundColor: _selectedSource.backgroundColor,
      category: _selectedSource.name,
      isExpense: false,
    );

    widget.onIncomeSaved?.call(newIncome);
    Navigator.of(context).pop(newIncome);
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
          'Add Income',
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
                // 1. Amount Input Field
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
                      return 'Please enter an income amount';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 2. Source Selector Dropdown Field
                _buildFieldLabel('Source'),
                InkWell(
                  onTap: _chooseSource,
                  borderRadius: BorderRadius.circular(16),
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      key: ValueKey(_selectedSource.name),
                      initialValue: _selectedSource.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Select Source',
                        prefixIcon: _selectedSource.icon,
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Date Field (Auto-filled with tap to change)
                _buildFieldLabel('Date (Auto-filled)'),
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

                // 4. Description Multi-line Field
                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add details about this income...',
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
                const SizedBox(height: 36),

                // 5. Save Income Primary CTA
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
        onPressed: _submitIncome,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Save Income',
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
