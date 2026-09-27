import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../components/home/home_header.dart';
import '../../components/home/penny_pal_drawer.dart';
import '../../components/home/total_balance_card.dart';
import '../../components/home/summary_cards_section.dart';
import '../../components/home/dashboard_charts_section.dart';
import '../../components/home/recent_transactions_section.dart';
import '../../components/home/custom_bottom_nav_bar.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/all_expenses_screen.dart';
import '../../components/expenses/expense_detail_sheet.dart';
import '../income/add_income_screen.dart';
import '../budgets/budgets_screen.dart';
import '../budgets/add_budget_screen.dart';
import '../../models/budget_model.dart';
import '../goals/savings_goals_screen.dart';
import '../goals/add_saving_goal_screen.dart';
import '../../models/saving_goal_model.dart';
import '../reports/reports_screen.dart';
import '../learning/learning_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';
import '../../components/common/sync_status_badge.dart';
import '../../core/repository/pennypal_repository.dart';
import '../../core/auth/auth_service.dart';
import '../../core/localization/language_service.dart';
import '../../components/Auth/LoginScreen.dart';
import 'dart:async';

/// Main HomeScreen for the PennyPal application.
/// Built with clean, human-readable component-based architecture,
/// sticky app bar, and a dedicated PennyPal navigation drawer.
class HomeScreen extends StatefulWidget {
  final String userName;
  final VoidCallback? onLogout;

  const HomeScreen({
    super.key,
    this.userName = 'Mohd Jaffari',
    this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<SavingsGoalsScreenState> _goalsKey = GlobalKey<SavingsGoalsScreenState>();
  int _currentTabIndex = 0;
  bool _useSparklineStyle = false;

  List<TransactionModel> _transactions = [];
  List<SavingGoalModel> _goals = [];
  StreamSubscription<List<TransactionModel>>? _txSub;
  StreamSubscription<List<SavingGoalModel>>? _goalSub;

  @override
  void initState() {
    super.initState();
    AuthService.instance.init();
    _loadDataFromDatabase();
    _txSub = PennyPalRepository.instance.transactionsStream.listen((list) {
      if (mounted) {
        setState(() => _transactions = List.from(list));
      }
    });
    _goalSub = PennyPalRepository.instance.goalsStream.listen((list) {
      if (mounted) {
        setState(() => _goals = List.from(list));
      }
    });
  }

  Future<void> _loadDataFromDatabase() async {
    final list = await PennyPalRepository.instance.getTransactions();
    final goals = await PennyPalRepository.instance.getGoals();
    if (mounted) {
      setState(() {
        _transactions = List.from(list);
        _goals = List.from(goals);
      });
    }
  }

  @override
  void dispose() {
    _txSub?.cancel();
    _goalSub?.cancel();
    super.dispose();
  }

  double get _totalIncome => _transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpenses => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalBalance => _totalIncome - _totalExpenses;

  double get _totalSavings => _goals
      .fold(0.0, (sum, g) => sum + g.currentAmount);

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = absAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return isNegative ? '-Rs. $formatted' : 'Rs. $formatted';
  }

  void _openAddExpense() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in or create an account to record your expenses.',
    );
    if (!authorized || !mounted) return;

    final newExpense = await Navigator.of(context).push<TransactionModel>(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          onExpenseSaved: (created) async {
            await PennyPalRepository.instance.addTransaction(created);
          },
        ),
      ),
    );

    if (newExpense != null && mounted) {
      await _loadDataFromDatabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense added: ${newExpense.formattedAmount}'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _openAddIncome() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in or create an account to record your income.',
    );
    if (!authorized || !mounted) return;

    final newIncome = await Navigator.of(context).push<TransactionModel>(
      MaterialPageRoute(
        builder: (context) => AddIncomeScreen(
          onIncomeSaved: (created) async {
            await PennyPalRepository.instance.addTransaction(created);
          },
        ),
      ),
    );

    if (newIncome != null && mounted) {
      await _loadDataFromDatabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Income recorded: ${newIncome.formattedAmount}'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _openAddGoal() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in or create an account to set savings goals.',
    );
    if (!authorized || !mounted) return;

    final newGoal = await Navigator.of(context).push<SavingGoalModel>(
      MaterialPageRoute(
        builder: (context) => AddSavingGoalScreen(
          onGoalSaved: (goal) async {
            await PennyPalRepository.instance.saveGoal(goal);
            _goalsKey.currentState?.addGoal(goal);
          },
        ),
      ),
    );

    if (newGoal != null && mounted) {
      setState(() => _currentTabIndex = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goal "${newGoal.title}" created successfully!'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _openAddBudget() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in or create an account to set a category budget.',
    );
    if (!authorized || !mounted) return;

    final newBudget = await Navigator.of(context).push<CategoryBudgetModel>(
      MaterialPageRoute(
        builder: (context) => const AddBudgetScreen(),
      ),
    );

    if (newBudget != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget created for ${newBudget.category}!'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'View Budgets',
            textColor: Colors.white,
            onPressed: _openBudgets,
          ),
        ),
      );
    }
  }

  void _showQuickActionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.borderOf(context), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 14),
                Text(
                  context.tr('record_entry'),
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                _buildQuickActionTile(
                  ctx,
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.primaryPink,
                  bgColor: AppColors.primaryPinkLight,
                  title: context.tr('add_expense_quick'),
                  subtitle: context.tr('add_expense_desc'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openAddExpense();
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickActionTile(
                  ctx,
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.successGreen,
                  bgColor: AppColors.successGreenLight,
                  title: context.tr('add_income_quick'),
                  subtitle: context.tr('add_income_desc'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openAddIncome();
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickActionTile(
                  ctx,
                  icon: Icons.track_changes_rounded,
                  iconColor: AppColors.purple,
                  bgColor: AppColors.purpleLight,
                  title: context.tr('add_goal_quick'),
                  subtitle: context.tr('add_goal_desc'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openAddGoal();
                  },
                ),
                const SizedBox(height: 8),
                _buildQuickActionTile(
                  ctx,
                  icon: Icons.donut_small_rounded,
                  iconColor: AppColors.shoppingOrange,
                  bgColor: AppColors.shoppingOrangeLight,
                  title: context.tr('set_budget_quick'),
                  subtitle: context.tr('set_budget_desc'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openAddBudget();
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext ctx, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = AppColors.isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceMuted : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.22) : bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_ios_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: AppColors.textMutedOf(context),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSavingsGoals() {
    setState(() => _currentTabIndex = 2);
  }

  void _openReports() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in to view detailed financial analytics and reports.',
    );
    if (!authorized || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReportsScreen(),
      ),
    );
  }

  void _openLearning() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LearningScreen(),
      ),
    );
  }

  void _openNotifications() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in to view personal alerts and notifications.',
    );
    if (!authorized || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  void _openSettings() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in to configure security and account settings.',
    );
    if (!authorized || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openProfile() async {
    final authorized = await AuthService.instance.requireAuth(
      context,
      reason: 'Please log in or create an account to view and manage your profile.',
    );
    if (!authorized || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          initialName: AuthService.instance.userName,
          initialRole: AuthService.instance.isLoggedIn ? 'Student Plan' : 'Guest Account',
        ),
      ),
    );
  }

  void _openBudgets() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BudgetsScreen(),
      ),
    );
  }

  void _openAllExpenses() {
    setState(() => _currentTabIndex = 1);
  }

  void _handleDrawerSelection(int index) {
    if (index == 0) {
      setState(() => _currentTabIndex = 0);
      return;
    }
    if (index == 1) {
      _openAllExpenses();
      return;
    }
    if (index == 2) {
      _openBudgets();
      return;
    }
    if (index == 3) {
      _openSavingsGoals();
      return;
    }
    if (index == 4) {
      _openReports();
      return;
    }
    if (index == 6) {
      _openLearning();
      return;
    }
    if (index == 7) {
      _openNotifications();
      return;
    }
    if (index == 8) {
      _openSettings();
      return;
    }
    if (index < 4) {
      setState(() => _currentTabIndex = index);
    } else {
      // Feature or Settings tapped from drawer
      final labels = [
        'Dashboard',
        'All Expenses',
        'Budgets',
        'Savings Goals',
        'Reports & Analytics',
        'AI Assistant (Penny)',
        'Financial Learning',
        'Notifications',
        'Settings',
      ];
      final title = index < labels.length ? labels[index] : 'Section';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title selected'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  PreferredSizeWidget _buildCurrentAppBar() {
    switch (_currentTabIndex) {
      case 1:
        return HomeHeader(
          title: '${context.tr('all_expenses')} 🧾',
          subtitle: context.tr('track_analyze_spending'),
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          actions: [
            HomeHeader.circularButton(
              icon: Icons.notifications_none_rounded,
              onTap: _openNotifications,
              tooltip: 'Notifications',
              badge: Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceOf(context),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case 2:
        return HomeHeader(
          title: '${context.tr('saving_goals')} 🎯',
          subtitle: context.tr('smart_targets_desc'),
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          actions: [
            HomeHeader.circularButton(
              icon: Icons.notifications_none_rounded,
              onTap: _openNotifications,
              tooltip: 'Notifications',
              badge: Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceOf(context),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return HomeHeader(
          userName: AuthService.instance.userName,
          subtitle: AuthService.instance.isLoggedIn
              ? context.tr('header_subtitle')
              : context.tr('guest_welcome'),
          hasUnreadNotification: AuthService.instance.isLoggedIn,
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          onNotificationPressed: _openNotifications,
        );
    }
  }

  Widget _buildCurrentBody() {
    switch (_currentTabIndex) {
      case 1:
        return SafeArea(
          child: AllExpensesScreen(
            isEmbedded: true,
            initialExpenses: _transactions,
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            onExpensesChanged: (updated) {
              setState(() {
                _transactions
                  ..clear()
                  ..addAll(updated);
              });
            },
          ),
        );
      case 2:
        return SafeArea(
          child: SavingsGoalsScreen(
            key: _goalsKey,
            isEmbedded: true,
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        );
      default:
        return _buildDashboardBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundOf(context),

      // 1. Sleek, Sticky Unified App Bar across Home, Expenses, and Goals
      appBar: _buildCurrentAppBar(),

      // 2. PennyPal Custom Navigation Drawer
      drawer: PennyPalDrawer(
        userName: AuthService.instance.userName,
        userRole: AuthService.instance.isLoggedIn ? 'Student Plan' : 'Guest Mode',
        balance: _formatCurrency(_totalBalance),
        expenses: _formatCurrency(_totalExpenses),
        savings: _formatCurrency(_totalSavings),
        selectedIndex: _currentTabIndex == 2 ? 3 : _currentTabIndex,
        isLoggedIn: AuthService.instance.isLoggedIn,
        onProfileTap: _openProfile,
        onDestinationSelected: _handleDrawerSelection,
        onLogout: widget.onLogout,
        onLogin: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
          if ((result == true || AuthService.instance.isLoggedIn) && mounted) {
            setState(() {});
          }
        },
      ),

      // 3. Dynamic Body: Home (tab 0), Expenses (tab 1), or Goals (tab 2)
      body: _buildCurrentBody(),

      // 4. Floating Action Button with Pink Gradient
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final authorized = await AuthService.instance.requireAuth(
            context,
            reason: 'Please log in or create an account to record new transactions or budgets.',
          );
          if (!authorized || !mounted) return;
          _showQuickActionSheet();
        },
        tooltip: 'Record Transaction',
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.pinkGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 5. Custom Notched Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentTabIndex,
        onTabSelected: (index) {
          if (index == 3) {
            _openProfile();
          } else {
            setState(() => _currentTabIndex = index);
          }
        },
      ),
    );
  }

  Widget _buildDashboardBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real-time Offline SQLite & Firebase Sync Badge
          const SyncStatusBadge(),

          // Total Balance Card (Tap to toggle between Figma design & Sparkline graph variant)
          GestureDetector(
            onTap: () {
              setState(() {
                _useSparklineStyle = !_useSparklineStyle;
              });
            },
            child: TotalBalanceCard(
              balance: _formatCurrency(_totalBalance),
              trendPercentage: _transactions.isEmpty ? 'Start tracking' : '+12% this month',
              isTrendPositive: _totalBalance >= 0,
              useSparklineStyle: _useSparklineStyle,
            ),
          ),
          const SizedBox(height: 18),

          // Summary Metrics: Expenses & Savings Cards
          SummaryCardsSection(
            expensesAmount: _formatCurrency(_totalExpenses),
            expensesTrend: _transactions.isEmpty ? '0 entries' : '- 8% this month',
            savingsAmount: _formatCurrency(_totalSavings),
            savingsTrend: _goals.isEmpty ? '0 goals set' : '+ 20% this month',
            onExpensesTap: _openAllExpenses,
            onSavingsTap: _openSavingsGoals,
          ),
          const SizedBox(height: 24),

          // Interactive Financial Analytics & Charts Section (Weekly Bar, Category Donut, Savings Ring)
          DashboardChartsSection(
            transactions: _transactions,
            goals: _goals,
          ),
          const SizedBox(height: 24),

          // Recent Transactions List
          RecentTransactionsSection(
            transactions: _transactions,
            onViewAllPressed: _openAllExpenses,
            onTransactionTap: (tx) {
              ExpenseDetailSheet.show(
                context,
                transaction: tx,
                onDelete: () async {
                  await PennyPalRepository.instance.deleteTransaction(tx.id);
                  final updated = await PennyPalRepository.instance.getTransactions();
                  if (mounted) {
                    setState(() {
                      _transactions
                        ..clear()
                        ..addAll(updated);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${tx.title} deleted'),
                        backgroundColor: AppColors.expenseRed,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                onEdit: () {
                  final messenger = ScaffoldMessenger.of(context);
                  if (tx.isExpense) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddExpenseScreen(
                          initialExpense: tx,
                          onExpenseSaved: (updated) async {
                            await PennyPalRepository.instance.saveTransaction(updated);
                            final refreshed = await PennyPalRepository.instance.getTransactions();
                            if (mounted) {
                              setState(() {
                                _transactions
                                  ..clear()
                                  ..addAll(refreshed);
                              });
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Expense "${updated.title}" updated successfully!'),
                                  backgroundColor: AppColors.successGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddIncomeScreen(
                          initialIncome: tx,
                          onIncomeSaved: (updated) async {
                            await PennyPalRepository.instance.saveTransaction(updated);
                            final refreshed = await PennyPalRepository.instance.getTransactions();
                            if (mounted) {
                              setState(() {
                                _transactions
                                  ..clear()
                                  ..addAll(refreshed);
                              });
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Income "${updated.title}" updated successfully!'),
                                  backgroundColor: AppColors.successGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),

          // Bottom padding to ensure content doesn't collide with the notched nav bar
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
