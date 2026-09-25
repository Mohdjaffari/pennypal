import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_chart_models.dart';
import '../../components/reports/time_period_filter.dart';
import '../../components/reports/bar_chart_card.dart';
import '../../components/reports/category_breakdown_card.dart';

/// Screen representing the Reports & Analytics view in PennyPal.
/// Features dynamic period switching, interactive bar trends, and category breakdown.
class ReportsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ReportsScreen({super.key, this.onBack});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Weekly';

  // --- Dynamic Mock Data Sets ---

  // 1. Weekly Data
  final List<BarChartDataPoint> _weeklyData = const [
    BarChartDataPoint(label: 'Mon', percentage: 0.45, color: AppColors.primaryPink, amount: 450),
    BarChartDataPoint(label: 'Tue', percentage: 0.65, color: AppColors.primaryBlue, amount: 650),
    BarChartDataPoint(label: 'Wed', percentage: 0.30, color: AppColors.shoppingOrange, amount: 300),
    BarChartDataPoint(label: 'Thu', percentage: 0.85, color: AppColors.successGreen, amount: 850),
    BarChartDataPoint(label: 'Fri', percentage: 0.50, color: AppColors.purple, amount: 500),
    BarChartDataPoint(label: 'Sat', percentage: 0.95, color: AppColors.primaryPink, amount: 950),
    BarChartDataPoint(label: 'Sun', percentage: 0.70, color: AppColors.primaryBlue, amount: 700),
  ];

  // 2. Monthly Data (4 Weeks)
  final List<BarChartDataPoint> _monthlyData = const [
    BarChartDataPoint(label: 'W 1', percentage: 0.60, color: AppColors.primaryBlue, amount: 2400),
    BarChartDataPoint(label: 'W 2', percentage: 0.85, color: AppColors.primaryPink, amount: 3200),
    BarChartDataPoint(label: 'W 3', percentage: 0.45, color: AppColors.shoppingOrange, amount: 1800),
    BarChartDataPoint(label: 'W 4', percentage: 0.70, color: AppColors.successGreen, amount: 2800),
  ];

  // 3. Yearly Data (Last 5 Years)
  final List<BarChartDataPoint> _yearlyData = const [
    BarChartDataPoint(label: '2022', percentage: 0.50, color: AppColors.textSecondary),
    BarChartDataPoint(label: '2023', percentage: 0.65, color: AppColors.primaryBlue),
    BarChartDataPoint(label: '2024', percentage: 0.75, color: AppColors.purple),
    BarChartDataPoint(label: '2025', percentage: 0.90, color: AppColors.shoppingOrange),
    BarChartDataPoint(label: '2026', percentage: 0.80, color: AppColors.primaryPink),
  ];

  // Category Breakdown Data (Figma Screen 12)
  final List<CategorySpendingData> _categoryData = const [
    CategorySpendingData(
      name: 'Food & Dining',
      percentage: 0.34,
      color: AppColors.primaryPink,
      amount: 2800,
    ),
    CategorySpendingData(
      name: 'Transport',
      percentage: 0.20,
      color: AppColors.primaryBlue,
      amount: 1650,
    ),
    CategorySpendingData(
      name: 'Shopping',
      percentage: 0.18,
      color: AppColors.shoppingOrange,
      amount: 1480,
    ),
    CategorySpendingData(
      name: 'Entertainment',
      percentage: 0.12,
      color: AppColors.successGreen,
      amount: 990,
    ),
    CategorySpendingData(
      name: 'Others',
      percentage: 0.16,
      color: AppColors.purple,
      amount: 1310,
    ),
  ];

  List<BarChartDataPoint> get _currentDataPoints {
    switch (_selectedPeriod) {
      case 'Monthly':
        return _monthlyData;
      case 'Yearly':
        return _yearlyData;
      case 'Weekly':
      default:
        return _weeklyData;
    }
  }

  String get _currentTotalSpent {
    switch (_selectedPeriod) {
      case 'Monthly':
        return 'Rs. 10,200';
      case 'Yearly':
        return 'Rs. 124,500';
      case 'Weekly':
      default:
        return 'Rs. 4,400';
    }
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
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 21),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Financial report ready to export'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
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
              const SizedBox(height: 24),

              // 2. Responsive Bar Chart
              BarChartCard(
                dataPoints: _currentDataPoints,
                title: 'Total Spent this $_selectedPeriod',
                subtitle: _currentTotalSpent,
              ),
              const SizedBox(height: 32),

              // 3. Spending by Category (Doughnut Chart + Legend)
              CategoryBreakdownCard(
                categories: _categoryData,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
