import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';

/// Modal Bottom Sheet allowing users to add an expense,
/// replicating the "Add Expense" screen from the PennyPal design system.
class AddExpenseSheet extends StatefulWidget {
  final ValueChanged<TransactionModel> onExpenseAdded;

  const AddExpenseSheet({
    super.key,
    required this.onExpenseAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<TransactionModel> onExpenseAdded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseSheet(onExpenseAdded: onExpenseAdded),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  String _selectedCategory = 'Food & Dining';
  String _selectedPaymentMethod = 'Debit Card';
  final DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.primaryPink,
      'bgColor': AppColors.primaryPinkLight,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_bus_rounded,
      'color': AppColors.primaryBlue,
      'bgColor': AppColors.primaryBlueLight,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.shoppingOrange,
      'bgColor': AppColors.shoppingOrangeLight,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie_rounded,
      'color': AppColors.purple,
      'bgColor': AppColors.purpleLight,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitExpense() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final catData = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
      orElse: () => _categories.first,
    );

    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : _selectedCategory,
      date: 'Today, ${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
      amount: amount,
      icon: catData['icon'] as IconData,
      color: catData['color'] as Color,
      backgroundColor: catData['bgColor'] as Color,
      category: _selectedCategory,
      isExpense: true,
    );

    widget.onExpenseAdded(newTx);
    Navigator.of(context).pop();
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final inputFill = isDark ? AppColors.darkSurfaceMuted : AppColors.background;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Expense',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Input
            Text(
              'Amount',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                prefixText: 'Rs. ',
                prefixStyle: const TextStyle(
                  color: AppColors.primaryPink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                hintText: '0',
                hintStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Category Selector
            Text(
              'Category',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final isSelected = _selectedCategory == c['name'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        c['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : (c['color'] as Color),
                      ),
                      const SizedBox(width: 6),
                      Text(c['name'] as String),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: inputFill,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textPrimary,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : borderColor,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = c['name'] as String);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Payment Method
            Text(
              'Payment Method',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Debit Card', 'Cash', 'Online'].map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(method),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: inputFill,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textPrimary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : borderColor,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPaymentMethod = method);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Note (Optional)
            Text(
              'Note (Optional)',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              style: TextStyle(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Lunch with team or Grocery run',
                hintStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // Save Expense Button (Full width pink gradient button)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primaryPink.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Expense',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
