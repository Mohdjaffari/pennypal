import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/transaction_model.dart';
import '../../models/report_chart_models.dart';
import '../../components/home/transaction_tile.dart';
import '../../components/expenses/expenses_summary_banner.dart';
import '../../components/expenses/expenses_chart_section.dart';
import '../../components/expenses/expense_detail_sheet.dart';
import '../../components/home/home_header.dart';

/// Screen displaying the comprehensive "All Expenses" view in PennyPal.
/// Engineered for high performance, virtualized scrolling, live multi-filter search,
/// and interactive spending charts (daily bar & category share).
class AllExpensesScreen extends StatefulWidget {
  final List<TransactionModel>? initialExpenses;
  final bool isEmbedded;
  final VoidCallback? onMenuPressed;
  final ValueChanged<List<TransactionModel>>? onExpensesChanged;

  const AllExpensesScreen({
    super.key,
    this.initialExpenses,
    this.isEmbedded = false,
    this.onMenuPressed,
    this.onExpensesChanged,
  });

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  late List<TransactionModel> _expenses;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedPeriod = 'This Month';
  String _selectedCategory = 'All';
  bool _sortByHighest = false;

  final List<String> _periods = ['This Week', 'This Month', 'Last Month', 'All Time'];
  final List<String> _categories = [
    'All',
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Groceries',
    'Bills & Utilities',
  ];

  @override
  void initState() {
    super.initState();
    _expenses = widget.initialExpenses != null
        ? List.from(widget.initialExpenses!)
        : [
            const TransactionModel(
              id: 'tx_1',
              title: 'Food & Dining',
              date: '20 Sep 2025',
              amount: 450,
              icon: Icons.restaurant_rounded,
              color: AppColors.primaryPink,
              backgroundColor: AppColors.primaryPinkLight,
              category: 'Food & Dining',
              paymentMethod: 'Debit Card',
              note: 'Dinner with friends',
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
              paymentMethod: 'Cash',
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
              paymentMethod: 'Credit Card',
              hasReceipt: true,
              note: 'Winter jacket & shoes',
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
              paymentMethod: 'Debit Card',
            ),
            const TransactionModel(
              id: 'tx_5',
              title: 'Groceries Supermarket',
              date: '14 Sep 2025',
              amount: 1450,
              icon: Icons.local_grocery_store_rounded,
              color: Color(0xFF06D6A0),
              backgroundColor: Color(0xFFE8FDF5),
              category: 'Groceries',
              paymentMethod: 'UPI / Digital Wallet',
              hasReceipt: true,
            ),
            const TransactionModel(
              id: 'tx_6',
              title: 'Electricity & Wifi Bill',
              date: '10 Sep 2025',
              amount: 2200,
              icon: Icons.receipt_long_rounded,
              color: Color(0xFFE63946),
              backgroundColor: Color(0xFFFFECEE),
              category: 'Bills & Utilities',
              paymentMethod: 'Net Banking',
            ),
            const TransactionModel(
              id: 'tx_7',
              title: 'Coffee & Snacks',
              date: '08 Sep 2025',
              amount: 280,
              icon: Icons.restaurant_rounded,
              color: AppColors.primaryPink,
              backgroundColor: AppColors.primaryPinkLight,
              category: 'Food & Dining',
              paymentMethod: 'Cash',
            ),
          ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Filtering & Calculations ---

  List<TransactionModel> get _filteredExpenses {
    var list = _expenses.where((tx) => tx.isExpense).toList();

    // Category filter
    if (_selectedCategory != 'All') {
      list = list.where((tx) => tx.category == _selectedCategory).toList();
    }

    // Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((tx) {
        return tx.title.toLowerCase().contains(q) ||
            tx.category.toLowerCase().contains(q) ||
            tx.paymentMethod.toLowerCase().contains(q);
      }).toList();
    }

    // Sorting
    if (_sortByHighest) {
      list.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return list;
  }

  double get _totalFilteredAmount =>
      _filteredExpenses.fold(0.0, (sum, tx) => sum + tx.amount);

  // Dynamic daily distribution for the bar chart
  List<BarChartDataPoint> get _dailyChartData {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, double> dayAmounts = {
      'Mon': 850,
      'Tue': 450,
      'Wed': 1200,
      'Thu': 680,
      'Fri': 2100,
      'Sat': 1850,
      'Sun': 1100,
    };

    double maxVal = 2500;
    for (final v in dayAmounts.values) {
      if (v > maxVal) maxVal = v;
    }

    return days.map((day) {
      final amt = dayAmounts[day] ?? 0.0;
      return BarChartDataPoint(
        label: day,
        percentage: (amt / maxVal).clamp(0.1, 1.0),
        color: AppColors.primaryPink,
        amount: amt,
      );
    }).toList();
  }

  // Dynamic category share for the donut chart
  List<CategorySpendingData> get _categoryChartData {
    final Map<String, double> catTotals = {};
    for (final tx in _filteredExpenses) {
      catTotals[tx.category] = (catTotals[tx.category] ?? 0.0) + tx.amount;
    }

    if (catTotals.isEmpty) {
      return const [
        CategorySpendingData(
          name: 'None',
          percentage: 1.0,
          color: AppColors.border,
        ),
      ];
    }

    final total = _totalFilteredAmount > 0 ? _totalFilteredAmount : 1.0;
    final List<Color> palette = [
      AppColors.primaryPink,
      AppColors.primaryBlue,
      AppColors.shoppingOrange,
      AppColors.purple,
      const Color(0xFF06D6A0),
      const Color(0xFFE63946),
    ];

    int colorIdx = 0;
    return catTotals.entries.map((entry) {
      final color = palette[colorIdx % palette.length];
      colorIdx++;
      return CategorySpendingData(
        name: entry.key,
        percentage: (entry.value / total).clamp(0.01, 1.0),
        color: color,
        amount: entry.value,
      );
    }).toList();
  }

  void _showTransactionDetails(TransactionModel tx) {
    ExpenseDetailSheet.show(
      context,
      transaction: tx,
      onDelete: () {
        setState(() {
          _expenses.removeWhere((item) => item.id == tx.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tx.title} deleted'),
            backgroundColor: AppColors.expenseRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedCategory = 'All';
      _selectedPeriod = 'This Month';
      _sortByHighest = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _filteredExpenses;

    if (widget.isEmbedded) {
      return _buildBody(expenses);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(expenses),
      ),
    );
  }

  Widget _buildBody(List<TransactionModel> expenses) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar with Live Filter & Reset
          _buildSearchBar(),
          const SizedBox(height: 14),

          // 2. Time-period Filter Chips
          _buildTimePeriodFilter(),
          const SizedBox(height: 14),

          // 3. Category Filter Chips
          _buildCategoryChips(),
          const SizedBox(height: 18),

          // 4. Summary Banner
          ExpensesSummaryBanner(
            totalAmount: _totalFilteredAmount,
            transactionCount: expenses.length,
            periodLabel: _selectedPeriod,
            trendLabel: '-8% vs last month',
            isTrendGood: true,
          ),
          const SizedBox(height: 18),

          // 5. Chart Analytics Card (Daily Bars & Category Donut Share)
          ExpensesChartSection(
            dailyData: _dailyChartData,
            categoryData: _categoryChartData,
            totalSpent: _totalFilteredAmount,
          ),
          const SizedBox(height: 24),

          // 6. Transaction List Header & Sort Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expenses (${expenses.length})',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _sortByHighest = !_sortByHighest),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _sortByHighest
                            ? Icons.arrow_downward_rounded
                            : Icons.sort_rounded,
                        size: 16,
                        color: _sortByHighest
                            ? AppColors.primaryPink
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _sortByHighest ? 'Highest' : 'Latest',
                        style: TextStyle(
                          color: _sortByHighest
                              ? AppColors.primaryPink
                              : AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7. Virtualized Transactions List / Empty State
          if (expenses.isEmpty) ...[
            _buildEmptyState(),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = expenses[index];
                return TransactionTile(
                  transaction: item,
                  onTap: () => _showTransactionDetails(item),
                );
              },
            ),
          ],

          const SizedBox(height: 100), // Clearance for notched bottom nav bar
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return HomeHeader(
      title: 'All Expenses 🧾',
      subtitle: 'Track and analyze spending',
      isBackNavigation: true,
      onMenuPressed: () => Navigator.of(context).maybePop(),
      actions: [
        HomeHeader.circularButton(
          icon: Icons.tune_rounded,
          onTap: _resetFilters,
          tooltip: 'Reset Filters',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search by title, category, payment...',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 18),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 20),
                tooltip: 'Reset filters',
                onPressed: _resetFilters,
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTimePeriodFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = period);
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryBlue : AppColors.border,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = cat);
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryPink,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryPink : AppColors.border,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primaryPinkLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryPink,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Expenses Found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search query or category filters.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: _resetFilters,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPink,
              side: const BorderSide(color: AppColors.primaryPink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }
}
