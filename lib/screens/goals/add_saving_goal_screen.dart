import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/saving_goal_model.dart';

/// Screen allowing users to create a new Savings Goal.
/// Rebuilt with clean, human-readable architecture, real date selection,
/// category presets, and robust input validation.
class AddSavingGoalScreen extends StatefulWidget {
  final ValueChanged<SavingGoalModel>? onGoalSaved;

  const AddSavingGoalScreen({
    super.key,
    this.onGoalSaved,
  });

  @override
  State<AddSavingGoalScreen> createState() => _AddSavingGoalScreenState();
}

class _AddSavingGoalScreenState extends State<AddSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentSavingsController = TextEditingController();
  final TextEditingController _monthlyContributionController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();

  DateTime? _selectedTargetDate;
  late final String _creationDateString;

  // Preset categories for goals
  final List<Map<String, dynamic>> _goalCategories = [
    {
      'name': 'Laptop / Tech',
      'icon': Icons.laptop_mac_rounded,
      'color': AppColors.primaryPink,
      'bgColor': AppColors.primaryPinkLight,
    },
    {
      'name': 'Education',
      'icon': Icons.school_rounded,
      'color': AppColors.primaryBlue,
      'bgColor': AppColors.primaryBlueLight,
    },
    {
      'name': 'Travel & Trip',
      'icon': Icons.flight_takeoff_rounded,
      'color': AppColors.shoppingOrange,
      'bgColor': AppColors.shoppingOrangeLight,
    },
    {
      'name': 'Vehicle',
      'icon': Icons.directions_car_rounded,
      'color': AppColors.purple,
      'bgColor': AppColors.purpleLight,
    },
    {
      'name': 'Emergency Fund',
      'icon': Icons.shield_outlined,
      'color': AppColors.successGreen,
      'bgColor': AppColors.successGreenLight,
    },
  ];

  late Map<String, dynamic> _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _goalCategories.first;
    final now = DateTime.now();
    _creationDateString = '${now.day} ${_getMonthName(now.month)} ${now.year}';
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _currentSavingsController.dispose();
    _monthlyContributionController.dispose();
    _targetDateController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
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
      setState(() {
        _selectedTargetDate = picked;
        _targetDateController.text =
            '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      });
    }
  }

  void _submitGoal() {
    if (!_formKey.currentState!.validate()) return;

    final targetAmount = double.tryParse(_targetAmountController.text.trim()) ?? 0.0;
    final currentAmount = double.tryParse(_currentSavingsController.text.trim()) ?? 0.0;
    final monthly = double.tryParse(_monthlyContributionController.text.trim()) ?? 0.0;

    final newGoal = SavingGoalModel(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: _goalNameController.text.trim(),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      monthlyContribution: monthly,
      targetDate: _targetDateController.text.trim().isNotEmpty
          ? _targetDateController.text.trim()
          : 'No deadline',
      createdDate: _creationDateString,
      icon: _selectedCategory['icon'] as IconData,
      color: _selectedCategory['color'] as Color,
      backgroundColor: _selectedCategory['bgColor'] as Color,
    );

    widget.onGoalSaved?.call(newGoal);
    Navigator.of(context).pop(newGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Goal Category Selector (Presets)
                _buildFieldLabel('Category & Icon'),
                _buildCategorySelector(),
                const SizedBox(height: 20),

                // 2. Goal Name Field
                _buildFieldLabel('Goal Name'),
                TextFormField(
                  controller: _goalNameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _inputDecoration(
                    hint: 'e.g. New Laptop, Study Fund, Vacation',
                    prefixIcon: Icons.flag_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a goal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Target Amount Field
                _buildFieldLabel('Target Amount'),
                TextFormField(
                  controller: _targetAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: _inputDecoration(
                    hint: '0',
                    prefixText: 'Rs. ',
                    prefixIcon: Icons.account_balance_wallet_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please specify the target amount';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 4. Current Savings Field
                _buildFieldLabel('Initial / Current Savings'),
                TextFormField(
                  controller: _currentSavingsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _inputDecoration(
                    hint: '0',
                    prefixText: 'Rs. ',
                    prefixIcon: Icons.savings_outlined,
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Target Date Field (Interactive DatePicker)
                _buildFieldLabel('Target Date / Milestone'),
                TextFormField(
                  controller: _targetDateController,
                  readOnly: true,
                  onTap: _pickTargetDate,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _inputDecoration(
                    hint: 'Select target completion date',
                    prefixIcon: Icons.event_outlined,
                    suffixIcon: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primaryPink,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select a target date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 6. Monthly Contribution Field
                _buildFieldLabel('Monthly Contribution (Optional)'),
                TextFormField(
                  controller: _monthlyContributionController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _inputDecoration(
                    hint: '0 / month',
                    prefixText: 'Rs. ',
                    prefixIcon: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(height: 20),

                // 7. Creation Date Field (Auto-filled & Cleanly locked)
                _buildFieldLabel('Creation Date (Auto-filled)'),
                TextFormField(
                  readOnly: true,
                  initialValue: _creationDateString,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: _inputDecoration(
                    hint: '',
                    prefixIcon: Icons.lock_outline_rounded,
                    fillColor: AppColors.surfaceMuted,
                  ),
                ),
                const SizedBox(height: 36),

                // 8. Save Goal Button
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Add New Goal',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _goalCategories.map((cat) {
          final isSelected = _selectedCategory['name'] == cat['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : (cat['color'] as Color),
                  ),
                  const SizedBox(width: 6),
                  Text(cat['name'] as String),
                ],
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryPink,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.border,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = cat);
                  if (_goalNameController.text.trim().isEmpty) {
                    _goalNameController.text = cat['name'] as String;
                  }
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: fillColor ?? AppColors.surface,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: AppColors.primaryPink,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
          : null,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.expenseRed, width: 1.2),
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
        onPressed: _submitGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Save Goal',
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
