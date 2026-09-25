import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../components/home/home_header.dart';
import '../../components/home/penny_pal_drawer.dart';
import '../../components/home/total_balance_card.dart';
import '../../components/home/summary_cards_section.dart';
import '../../components/home/recent_transactions_section.dart';
import '../../components/home/custom_bottom_nav_bar.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/all_expenses_screen.dart';
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

  // Initial mock transactions accurately matching the PennyPal design
  late final List<TransactionModel> _transactions = [
    const TransactionModel(
      id: 'tx_1',
      title: 'Food & Dining',
      date: '20 Sep 2025',
      amount: 450,
      icon: Icons.restaurant_rounded,
      color: AppColors.primaryPink,
      backgroundColor: AppColors.primaryPinkLight,
      category: 'Food',
    ),
    const TransactionModel(
      id: 'tx_2',
      title: 'Transport',
      date: '19 Sep 2025',
      amount: 120,
      icon: Icons.directions_bus_rounded,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlueLight,
      category: 'Transport',
    ),
    const TransactionModel(
      id: 'tx_3',
      title: 'Shopping',
      date: '18 Sep 2025',
      amount: 2800,
      icon: Icons.shopping_bag_rounded,
      color: AppColors.shoppingOrange,
      backgroundColor: AppColors.shoppingOrangeLight,
      category: 'Shopping',
    ),
    const TransactionModel(
      id: 'tx_4',
      title: 'Entertainment',
      date: '15 Sep 2025',
      amount: 640,
      icon: Icons.movie_rounded,
      color: AppColors.purple,
      backgroundColor: AppColors.purpleLight,
      category: 'Entertainment',
    ),
  ];

  void _openAddExpense() async {
    final newExpense = await Navigator.of(context).push<TransactionModel>(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          onExpenseSaved: (created) {
            setState(() {
              _transactions.insert(0, created);
            });
          },
        ),
      ),
    );

    if (newExpense != null && mounted) {
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
    final newIncome = await Navigator.of(context).push<TransactionModel>(
      MaterialPageRoute(
        builder: (context) => AddIncomeScreen(
          onIncomeSaved: (created) {
            setState(() {
              _transactions.insert(0, created);
            });
          },
        ),
      ),
    );

    if (newIncome != null && mounted) {
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
    final newGoal = await Navigator.of(context).push<SavingGoalModel>(
      MaterialPageRoute(
        builder: (context) => AddSavingGoalScreen(
          onGoalSaved: (goal) {
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
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Record New Entry',
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                _buildQuickActionTile(
                  ctx,
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.primaryPink,
                  bgColor: AppColors.primaryPinkLight,
                  title: 'Add Expense',
                  subtitle: 'Record daily spending, food, bills or transport',
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
                  title: 'Add Income',
                  subtitle: 'Record salary, freelance, gifts or dividends',
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
                  title: 'Add Savings Goal',
                  subtitle: 'Set targets for gadgets, dream fund or travel',
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
                  title: 'Set Category Budget',
                  subtitle: 'Set monthly limits to stay disciplined',
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bgColor,
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
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 16,
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

  void _openReports() {
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

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          initialName: widget.userName,
          initialRole: 'Student Plan',
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
          title: 'All Expenses 🧾',
          subtitle: 'Track and analyze spending',
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
                      color: AppColors.surface,
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
          title: 'Savings Goals 🎯',
          subtitle: 'Smart targets & dream funds',
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
                      color: AppColors.surface,
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
          userName: widget.userName,
          subtitle: "Keep going! You're doing great!",
          hasUnreadNotification: true,
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
      backgroundColor: AppColors.background,

      // 1. Sleek, Sticky Unified App Bar across Home, Expenses, and Goals
      appBar: _buildCurrentAppBar(),

      // 2. PennyPal Custom Navigation Drawer
      drawer: PennyPalDrawer(
        userName: widget.userName,
        userRole: 'Student Plan',
        balance: 'Rs. 12,450',
        expenses: 'Rs. 8,230',
        savings: 'Rs. 3,200',
        selectedIndex: _currentTabIndex == 2 ? 3 : _currentTabIndex,
        onDestinationSelected: _handleDrawerSelection,
        onLogout: widget.onLogout,
      ),

      // 3. Dynamic Body: Home (tab 0), Expenses (tab 1), or Goals (tab 2)
      body: _buildCurrentBody(),

      // 4. Floating Action Button with Pink Gradient
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActionSheet,
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
          // Total Balance Card (Tap to toggle between Figma design & Sparkline graph variant)
          GestureDetector(
            onTap: () {
              setState(() {
                _useSparklineStyle = !_useSparklineStyle;
              });
            },
            child: TotalBalanceCard(
              balance: 'Rs. 12,450',
              trendPercentage: '+12% this month',
              isTrendPositive: true,
              useSparklineStyle: _useSparklineStyle,
            ),
          ),
          const SizedBox(height: 18),

          // Summary Metrics: Expenses & Savings Cards
          SummaryCardsSection(
            expensesAmount: 'Rs. 8,230',
            expensesTrend: '- 8% this month',
            savingsAmount: 'Rs. 3,200',
            savingsTrend: '+ 20% this month',
            onExpensesTap: _openAllExpenses,
            onSavingsTap: _openSavingsGoals,
          ),
          const SizedBox(height: 26),

          // Recent Transactions List
          RecentTransactionsSection(
            transactions: _transactions,
            onViewAllPressed: _openAllExpenses,
            onTransactionTap: (tx) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${tx.title}: ${tx.formattedAmount}'),
                  behavior: SnackBarBehavior.floating,
                ),
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
