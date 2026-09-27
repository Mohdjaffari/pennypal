import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/saving_goal_model.dart';
import '../../components/goals/saving_goal_card.dart';
import '../../components/home/home_header.dart';
import 'add_saving_goal_screen.dart';
import '../../core/repository/pennypal_repository.dart';
import '../../core/auth/auth_service.dart';
import '../../core/localization/language_service.dart';
import 'dart:async';

/// Screen representing the Savings Goals view from the PennyPal design system.
/// Displays active goals with progress bars, overview banner, and add goal action.
class SavingsGoalsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isEmbedded;
  final VoidCallback? onMenuPressed;
  final List<SavingGoalModel>? initialGoals;
  final ValueChanged<List<SavingGoalModel>>? onGoalsChanged;

  const SavingsGoalsScreen({
    super.key,
    this.onBack,
    this.isEmbedded = false,
    this.onMenuPressed,
    this.initialGoals,
    this.onGoalsChanged,
  });

  @override
  State<SavingsGoalsScreen> createState() => SavingsGoalsScreenState();
}

class SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  void openAddGoal() => _navigateToAddGoal();

  void addGoal(SavingGoalModel goal) async {
    await PennyPalRepository.instance.saveGoal(goal);
    setState(() {
      _goals.add(goal);
    });
    widget.onGoalsChanged?.call(_goals);
  }

  late List<SavingGoalModel> _goals = [];
  StreamSubscription<List<SavingGoalModel>>? _goalSub;

  @override
  void initState() {
    super.initState();
    _goals = widget.initialGoals != null
        ? List.from(widget.initialGoals!)
        : [];
    _loadGoalsFromDb();
    _goalSub = PennyPalRepository.instance.goalsStream.listen((list) {
      if (mounted) {
        setState(() => _goals = List.from(list));
      }
    });
  }

  @override
  void dispose() {
    _goalSub?.cancel();
    super.dispose();
  }

  Future<void> _loadGoalsFromDb() async {
    final list = await PennyPalRepository.instance.getGoals();
    if (mounted) {
      setState(() => _goals = List.from(list));
    }
  }

  Future<void> _navigateToAddGoal() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in or create an account to set a savings goal.',
    );
    if (!authorized || !mounted) return;

    final newGoal = await Navigator.of(context).push<SavingGoalModel>(
      MaterialPageRoute(
        builder: (context) => AddSavingGoalScreen(
          onGoalSaved: (goal) {
            addGoal(goal);
          },
        ),
      ),
    );

    if (newGoal != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${newGoal.title}" ${context.tr('goal_created')}'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _goals.length;

    if (widget.isEmbedded) {
      return _buildBody(activeCount);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: HomeHeader(
        title: '${context.tr('saving_goals')} 🎯',
        subtitle: context.tr('smart_targets_desc'),
        isBackNavigation: true,
        onMenuPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: _buildBody(activeCount),
      ),
    );
  }

  Widget _buildBody(int activeCount) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overview Banner (Matching "Your Goals: 2 Active Goals" from screenshot)
          _buildOverviewBanner(activeCount),
          const SizedBox(height: 20),

          // 2. Active Goals List or Empty State
          if (_goals.isEmpty) ...[
            _buildEmptyState(),
          ] else ...[
            ...List.generate(
              _goals.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: SavingGoalCard(
                  goal: _goals[index],
                  onTap: () {
                    _showGoalOptions(context, _goals[index]);
                  },
                  onAddMoney: () {
                    _showAddMoneySheet(context, _goals[index]);
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: 100), // Clearance for notched bottom nav bar
        ],
      ),
    );
  }

  Widget _buildOverviewBanner(int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryPink.withValues(alpha: 0.12)
            : AppColors.primaryPinkLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryPink.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPink.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Goals',
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count Active Goals in progress',
                  style: const TextStyle(
                    color: AppColors.primaryPink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: AppColors.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Goals Yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the central "+" button in the bottom navigation bar to set a new savings target!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryOf(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMoneySheet(BuildContext context, SavingGoalModel goal) {
    final amountController = TextEditingController();
    double addedAmount = 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.surfaceOf(context);
    final borderColor = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetContext, setModalState) {
          final double projectedCurrent = (goal.currentAmount + addedAmount);
          final double projectedRatio = goal.targetAmount > 0
              ? (projectedCurrent / goal.targetAmount).clamp(0.0, 1.0)
              : 0.0;
          final int projectedPct = (projectedRatio * 100).toInt();

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
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
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Header: Goal Title & Target
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isDark
                                ? goal.color.withValues(alpha: 0.2)
                                : goal.backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(goal.icon, color: goal.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Money to Goal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                              Text(
                                goal.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: goal.color.withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$projectedPct%',
                            style: TextStyle(
                              color: goal.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Interactive Progress Preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMutedOf(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current: Rs. ${goal.currentAmount.toInt()}',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Target: Rs. ${goal.targetAmount.toInt()}',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: projectedRatio,
                              backgroundColor: borderColor.withValues(alpha: 0.5),
                              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                              minHeight: 8,
                            ),
                          ),
                          if (addedAmount > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              'New Total: Rs. ${projectedCurrent.toInt()} (+Rs. ${addedAmount.toInt()})',
                              style: TextStyle(
                                color: goal.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amount Label
                    Text(
                      'Contribution Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Amount Text Field
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
                          child: Text(
                            'Rs.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: goal.color,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textSecondary.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceMutedOf(context),
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
                          borderSide: BorderSide(color: goal.color, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          addedAmount = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Quick Contribution Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [500, 1000, 2000, 5000].map((quick) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text('+ Rs. $quick'),
                              labelStyle: TextStyle(
                                color: goal.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              backgroundColor: goal.color.withValues(alpha: isDark ? 0.18 : 0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: goal.color.withValues(alpha: 0.3),
                                ),
                              ),
                              onPressed: () {
                                final currentVal = double.tryParse(amountController.text) ?? 0.0;
                                final nextVal = (currentVal + quick).toInt();
                                amountController.text = nextVal.toString();
                                setModalState(() {
                                  addedAmount = nextVal.toDouble();
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addedAmount <= 0
                            ? null
                            : () async {
                                final entered = double.tryParse(amountController.text) ?? 0.0;
                                if (entered <= 0) return;

                                Navigator.pop(ctx);
                                await PennyPalRepository.instance.addMoneyToGoal(goal.id, entered);
                                final updated = await PennyPalRepository.instance.getGoals();

                                if (mounted) {
                                  setState(() => _goals = List.from(updated));
                                  widget.onGoalsChanged?.call(_goals);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 10),
                                          Text('Added Rs. ${entered.toInt()} to ${goal.title}! 🎉'),
                                        ],
                                      ),
                                      backgroundColor: AppColors.successGreen,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goal.color,
                          disabledBackgroundColor: goal.color.withValues(alpha: 0.4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          addedAmount > 0
                              ? 'Add Rs. ${addedAmount.toInt()} to Goal'
                              : 'Enter an Amount',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGoalOptions(BuildContext context, SavingGoalModel goal) {
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                const SizedBox(height: 16),
                Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${goal.formattedProgressOverview} (${goal.progressPercentage}%)',
                  style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue),
                  title: Text(
                    context.tr('add_money'),
                    style: TextStyle(color: AppColors.textPrimaryOf(context)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddMoneySheet(context, goal);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.expenseRed),
                  title: Text(context.tr('delete'), style: const TextStyle(color: AppColors.expenseRed)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final goalDeletedMsg = '"${goal.title}" ${context.tr('goal_deleted')}';
                    await PennyPalRepository.instance.deleteGoal(goal.id);
                    if (mounted) {
                      setState(() => _goals.removeWhere((g) => g.id == goal.id));
                      widget.onGoalsChanged?.call(_goals);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(goalDeletedMsg),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
