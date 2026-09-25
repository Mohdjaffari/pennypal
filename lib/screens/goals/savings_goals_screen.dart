import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/saving_goal_model.dart';
import '../../components/goals/saving_goal_card.dart';
import '../../components/home/home_header.dart';
import 'add_saving_goal_screen.dart';

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

  void addGoal(SavingGoalModel goal) {
    setState(() {
      _goals.add(goal);
    });
    widget.onGoalsChanged?.call(_goals);
  }

  // Initial mock goals directly matching Screen 5 from the Figma design board
  late final List<SavingGoalModel> _goals = widget.initialGoals != null
      ? List.from(widget.initialGoals!)
      : [
          const SavingGoalModel(
            id: 'goal_1',
            title: 'New Laptop',
            targetAmount: 50000,
            currentAmount: 12000,
            monthlyContribution: 4000,
            targetDate: '15 Dec 2026',
            createdDate: '10 Jan 2026',
            icon: Icons.laptop_mac_rounded,
            color: AppColors.primaryPink,
            backgroundColor: AppColors.primaryPinkLight,
          ),
          const SavingGoalModel(
            id: 'goal_2',
            title: 'Study Fund',
            targetAmount: 30000,
            currentAmount: 8000,
            monthlyContribution: 2500,
            targetDate: '30 Aug 2026',
            createdDate: '15 Jan 2026',
            icon: Icons.school_rounded,
            color: AppColors.primaryBlue,
            backgroundColor: AppColors.primaryBlueLight,
          ),
        ];

  Future<void> _navigateToAddGoal() async {
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
          content: Text('Goal "${newGoal.title}" created successfully!'),
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
      backgroundColor: AppColors.background,
      appBar: HomeHeader(
        title: 'Savings Goals 🎯',
        subtitle: 'Smart targets & dream funds',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primaryPinkLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryPink.withValues(alpha: 0.15),
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
                const Text(
                  'Your Goals',
                  style: TextStyle(
                    color: AppColors.textPrimary,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlueLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: AppColors.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Active Goals Yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the central "+" button in the bottom navigation bar to set a new savings target!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalOptions(BuildContext context, SavingGoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${goal.formattedProgressOverview} (${goal.progressPercentage}%)',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue),
                  title: const Text('Add Money to this Goal'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contribution dialog coming soon!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.expenseRed),
                  title: const Text('Delete Goal', style: TextStyle(color: AppColors.expenseRed)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _goals.removeWhere((g) => g.id == goal.id));
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
