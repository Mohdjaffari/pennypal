import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_chart_models.dart';
import '../../components/home/home_header.dart';
import '../../components/reports/time_period_filter.dart';
import '../../components/reports/report_kpi_summary_cards.dart';
import '../../components/reports/income_vs_expense_chart_card.dart';
import '../../components/reports/cash_flow_trend_card.dart';
import '../../components/reports/bar_chart_card.dart';
import '../../components/reports/category_breakdown_card.dart';
import '../../components/reports/budget_health_card.dart';
import '../notifications/notifications_screen.dart';

/// Screen representing the Reports & Analytics view in PennyPal.
/// Provides institutional-grade personal financial analytics:
///   1. KPI Summary Cards (Income, Spending, Net Savings, Savings Rate)
///   2. Paired Inflow vs Outflow Double-Bar Comparison Chart
///   3. Smooth Bézier Spline Net Cash Flow Trajectory Curve
///   4. Category Spending Breakdown Donut with Legend
///   5. Category Budget Adherence & Health Utilization Gauges
///   6. Smart AI Financial Health Insights Banner
///   7. Unified HomeHeader with reliable back button and functional Notification bell
class ReportsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ReportsScreen({super.key, this.onBack});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Weekly';

  // ── 1. Weekly Data Sets ──────────────────────────────────────────────────
  final List<ComparisonBarDataPoint> _weeklyComparison = const [
    ComparisonBarDataPoint(label: 'Mon', incomeAmount: 1200, expenseAmount: 450, incomePct: 0.60, expensePct: 0.22),
    ComparisonBarDataPoint(label: 'Tue', incomeAmount: 600, expenseAmount: 650, incomePct: 0.30, expensePct: 0.32),
    ComparisonBarDataPoint(label: 'Wed', incomeAmount: 850, expenseAmount: 300, incomePct: 0.42, expensePct: 0.15),
    ComparisonBarDataPoint(label: 'Thu', incomeAmount: 1500, expenseAmount: 850, incomePct: 0.75, expensePct: 0.42),
    ComparisonBarDataPoint(label: 'Fri', incomeAmount: 900, expenseAmount: 500, incomePct: 0.45, expensePct: 0.25),
    ComparisonBarDataPoint(label: 'Sat', incomeAmount: 2000, expenseAmount: 950, incomePct: 1.0, expensePct: 0.48),
    ComparisonBarDataPoint(label: 'Sun', incomeAmount: 1100, expenseAmount: 700, incomePct: 0.55, expensePct: 0.35),
  ];

  final List<CashFlowTrendPoint> _weeklyTrend = const [
    CashFlowTrendPoint(label: 'Mon', value: 750, normalizedHeight: 0.35),
    CashFlowTrendPoint(label: 'Tue', value: 700, normalizedHeight: 0.32),
    CashFlowTrendPoint(label: 'Wed', value: 1250, normalizedHeight: 0.52),
    CashFlowTrendPoint(label: 'Thu', value: 1900, normalizedHeight: 0.70),
    CashFlowTrendPoint(label: 'Fri', value: 2300, normalizedHeight: 0.80),
    CashFlowTrendPoint(label: 'Sat', value: 3350, normalizedHeight: 0.98),
    CashFlowTrendPoint(label: 'Sun', value: 3750, normalizedHeight: 0.95),
  ];

  final List<BarChartDataPoint> _weeklyExpenseBars = const [
    BarChartDataPoint(label: 'Mon', percentage: 0.45, color: AppColors.primaryPink, amount: 450),
    BarChartDataPoint(label: 'Tue', percentage: 0.65, color: AppColors.primaryBlue, amount: 650),
    BarChartDataPoint(label: 'Wed', percentage: 0.30, color: AppColors.shoppingOrange, amount: 300),
    BarChartDataPoint(label: 'Thu', percentage: 0.85, color: AppColors.successGreen, amount: 850),
    BarChartDataPoint(label: 'Fri', percentage: 0.50, color: AppColors.purple, amount: 500),
    BarChartDataPoint(label: 'Sat', percentage: 0.95, color: AppColors.primaryPink, amount: 950),
    BarChartDataPoint(label: 'Sun', percentage: 0.70, color: AppColors.primaryBlue, amount: 700),
  ];

  // ── 2. Monthly Data Sets (4 Weeks) ───────────────────────────────────────
  final List<ComparisonBarDataPoint> _monthlyComparison = const [
    ComparisonBarDataPoint(label: 'Week 1', incomeAmount: 6500, expenseAmount: 2400, incomePct: 0.72, expensePct: 0.28),
    ComparisonBarDataPoint(label: 'Week 2', incomeAmount: 4800, expenseAmount: 3200, incomePct: 0.55, expensePct: 0.38),
    ComparisonBarDataPoint(label: 'Week 3', incomeAmount: 7200, expenseAmount: 1800, incomePct: 0.82, expensePct: 0.22),
    ComparisonBarDataPoint(label: 'Week 4', incomeAmount: 8500, expenseAmount: 2800, incomePct: 0.95, expensePct: 0.32),
  ];

  final List<CashFlowTrendPoint> _monthlyTrend = const [
    CashFlowTrendPoint(label: 'W 1', value: 4100, normalizedHeight: 0.35),
    CashFlowTrendPoint(label: 'W 2', value: 5700, normalizedHeight: 0.48),
    CashFlowTrendPoint(label: 'W 3', value: 11100, normalizedHeight: 0.80),
    CashFlowTrendPoint(label: 'W 4', value: 16800, normalizedHeight: 0.96),
  ];

  final List<BarChartDataPoint> _monthlyExpenseBars = const [
    BarChartDataPoint(label: 'W 1', percentage: 0.60, color: AppColors.primaryBlue, amount: 2400),
    BarChartDataPoint(label: 'W 2', percentage: 0.85, color: AppColors.primaryPink, amount: 3200),
    BarChartDataPoint(label: 'W 3', percentage: 0.45, color: AppColors.shoppingOrange, amount: 1800),
    BarChartDataPoint(label: 'W 4', percentage: 0.70, color: AppColors.successGreen, amount: 2800),
  ];

  // ── 3. Yearly Data Sets (5 Years) ─────────────────────────────────────────
  final List<ComparisonBarDataPoint> _yearlyComparison = const [
    ComparisonBarDataPoint(label: '2022', incomeAmount: 62000, expenseAmount: 42000, incomePct: 0.50, expensePct: 0.35),
    ComparisonBarDataPoint(label: '2023', incomeAmount: 78000, expenseAmount: 51000, incomePct: 0.62, expensePct: 0.42),
    ComparisonBarDataPoint(label: '2024', incomeAmount: 92000, expenseAmount: 59000, incomePct: 0.74, expensePct: 0.48),
    ComparisonBarDataPoint(label: '2025', incomeAmount: 115000, expenseAmount: 74000, incomePct: 0.90, expensePct: 0.60),
    ComparisonBarDataPoint(label: '2026', incomeAmount: 128000, expenseAmount: 82000, incomePct: 1.0, expensePct: 0.65),
  ];

  final List<CashFlowTrendPoint> _yearlyTrend = const [
    CashFlowTrendPoint(label: '2022', value: 20000, normalizedHeight: 0.32),
    CashFlowTrendPoint(label: '2023', value: 27000, normalizedHeight: 0.42),
    CashFlowTrendPoint(label: '2024', value: 33000, normalizedHeight: 0.54),
    CashFlowTrendPoint(label: '2025', value: 41000, normalizedHeight: 0.72),
    CashFlowTrendPoint(label: '2026', value: 46000, normalizedHeight: 0.90),
  ];

  final List<BarChartDataPoint> _yearlyExpenseBars = const [
    BarChartDataPoint(label: '2022', percentage: 0.50, color: AppColors.textSecondary, amount: 42000),
    BarChartDataPoint(label: '2023', percentage: 0.65, color: AppColors.primaryBlue, amount: 51000),
    BarChartDataPoint(label: '2024', percentage: 0.75, color: AppColors.purple, amount: 59000),
    BarChartDataPoint(label: '2025', percentage: 0.90, color: AppColors.shoppingOrange, amount: 74000),
    BarChartDataPoint(label: '2026', percentage: 0.80, color: AppColors.primaryPink, amount: 82000),
  ];

  // ── Category Spending Data ────────────────────────────────────────────────
  final List<CategorySpendingData> _categoryData = const [
    CategorySpendingData(
      name: 'Food & Dining',
      percentage: 0.34,
      color: AppColors.primaryPink,
      amount: 2800,
      icon: Icons.restaurant_rounded,
    ),
    CategorySpendingData(
      name: 'Transport',
      percentage: 0.20,
      color: AppColors.primaryBlue,
      amount: 1650,
      icon: Icons.directions_bus_rounded,
    ),
    CategorySpendingData(
      name: 'Shopping',
      percentage: 0.18,
      color: AppColors.shoppingOrange,
      amount: 1480,
      icon: Icons.shopping_bag_outlined,
    ),
    CategorySpendingData(
      name: 'Entertainment',
      percentage: 0.12,
      color: AppColors.successGreen,
      amount: 990,
      icon: Icons.movie_creation_outlined,
    ),
    CategorySpendingData(
      name: 'Education & Others',
      percentage: 0.16,
      color: AppColors.purple,
      amount: 1310,
      icon: Icons.school_outlined,
    ),
  ];

  // ── Budget Health Metrics ─────────────────────────────────────────────────
  final List<BudgetHealthMetric> _budgetMetrics = const [
    BudgetHealthMetric(
      category: 'Food & Dining',
      spent: 2800,
      budget: 3200,
      icon: Icons.restaurant_rounded,
      color: AppColors.primaryPink,
    ),
    BudgetHealthMetric(
      category: 'Transport',
      spent: 1650,
      budget: 2000,
      icon: Icons.directions_bus_rounded,
      color: AppColors.primaryBlue,
    ),
    BudgetHealthMetric(
      category: 'Shopping',
      spent: 1480,
      budget: 1500,
      icon: Icons.shopping_bag_outlined,
      color: AppColors.shoppingOrange,
    ),
    BudgetHealthMetric(
      category: 'Entertainment',
      spent: 990,
      budget: 1400,
      icon: Icons.movie_creation_outlined,
      color: AppColors.successGreen,
    ),
  ];

  // ── Dynamic Getters ───────────────────────────────────────────────────────
  List<ComparisonBarDataPoint> get _currentComparison {
    switch (_selectedPeriod) {
      case 'Monthly':
        return _monthlyComparison;
      case 'Yearly':
        return _yearlyComparison;
      case 'Weekly':
      default:
        return _weeklyComparison;
    }
  }

  List<CashFlowTrendPoint> get _currentTrend {
    switch (_selectedPeriod) {
      case 'Monthly':
        return _monthlyTrend;
      case 'Yearly':
        return _yearlyTrend;
      case 'Weekly':
      default:
        return _weeklyTrend;
    }
  }

  List<BarChartDataPoint> get _currentExpenseBars {
    switch (_selectedPeriod) {
      case 'Monthly':
        return _monthlyExpenseBars;
      case 'Yearly':
        return _yearlyExpenseBars;
      case 'Weekly':
      default:
        return _weeklyExpenseBars;
    }
  }

  String get _currentTotalIncome {
    switch (_selectedPeriod) {
      case 'Monthly':
        return 'Rs. 27,000';
      case 'Yearly':
        return 'Rs. 128,000';
      case 'Weekly':
      default:
        return 'Rs. 8,150';
    }
  }

  String get _currentTotalSpent {
    switch (_selectedPeriod) {
      case 'Monthly':
        return 'Rs. 10,200';
      case 'Yearly':
        return 'Rs. 82,000';
      case 'Weekly':
      default:
        return 'Rs. 4,400';
    }
  }

  String get _currentNetSavings {
    switch (_selectedPeriod) {
      case 'Monthly':
        return '+Rs. 16,800';
      case 'Yearly':
        return '+Rs. 46,000';
      case 'Weekly':
      default:
        return '+Rs. 3,750';
    }
  }

  String get _currentSavingsRate {
    switch (_selectedPeriod) {
      case 'Monthly':
        return '62.2%';
      case 'Yearly':
        return '35.9%';
      case 'Weekly':
      default:
        return '46.0%';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: HomeHeader(
        title: 'Reports & Analytics',
        subtitle: 'Cash flow & spending insights',
        isBackNavigation: true,
        onMenuPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        onNotificationPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationsScreen(),
            ),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Time Period Filter (Weekly / Monthly / Yearly)
              TimePeriodFilter(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: (period) {
                  setState(() => _selectedPeriod = period);
                },
              ),
              const SizedBox(height: 18),

              // 2. High-Impact KPI Performance Metric Cards
              ReportKpiSummaryCards(
                totalIncome: _currentTotalIncome,
                totalExpenses: _currentTotalSpent,
                netSavings: _currentNetSavings,
                savingsRate: _currentSavingsRate,
                incomeTrend: '+12% this $_selectedPeriod',
                expenseTrend: '-8% this $_selectedPeriod',
              ),
              const SizedBox(height: 24),

              // 3. Paired Inflow vs Outflow Double-Bar Comparison Chart
              IncomeVsExpenseChartCard(
                dataPoints: _currentComparison,
                title: 'Inflow vs Outflow',
                period: _selectedPeriod,
              ),
              const SizedBox(height: 24),

              // 4. Smooth Bézier Spline Net Cash Flow Trajectory Curve
              CashFlowTrendCard(
                trendPoints: _currentTrend,
                period: _selectedPeriod,
                netSavings: _currentNetSavings,
              ),
              const SizedBox(height: 24),

              // 5. Category Budget Utilization & Health Monitor
              BudgetHealthCard(
                metrics: _budgetMetrics,
              ),
              const SizedBox(height: 24),

              // 6. Category Spending Donut Chart Breakdown
              CategoryBreakdownCard(
                categories: _categoryData,
              ),
              const SizedBox(height: 24),

              // 7. Spending by Day Bar Chart
              BarChartCard(
                dataPoints: _currentExpenseBars,
                title: 'Daily Spending Breakdown',
                subtitle: _currentTotalSpent,
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
