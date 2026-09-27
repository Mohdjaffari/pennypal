import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/transaction_model.dart';
import '../../models/saving_goal_model.dart';
import '../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardChartsSection
// Displays three professional charts on the home dashboard:
//   1. Weekly Income vs Expense Bar Chart
//   2. Spending by Category Donut Chart
//   3. Savings Progress Ring
// Pure CustomPainter — no external chart libraries required.
// ─────────────────────────────────────────────────────────────────────────────

class DashboardChartsSection extends StatefulWidget {
  final List<TransactionModel> transactions;
  final List<SavingGoalModel> goals;

  const DashboardChartsSection({
    super.key,
    required this.transactions,
    required this.goals,
  });

  @override
  State<DashboardChartsSection> createState() => _DashboardChartsSectionState();
}

enum ChartTimeframe {
  thisWeek,
  last7Days,
  thisMonth,
}

class _DashboardChartsSectionState extends State<DashboardChartsSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _anim;
  int _selectedBarIndex = -1;
  int _selectedDonutIndex = -1;
  ChartTimeframe _timeframe = ChartTimeframe.thisWeek;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void didUpdateWidget(DashboardChartsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactions.length != oldWidget.transactions.length ||
        widget.goals.length != oldWidget.goals.length) {
      _animCtrl.reset();
      _animCtrl.forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Data derivations ──────────────────────────────────────────────────────

  List<_DayBarData> get _weeklyData {
    final now = DateTime.now();
    final days = <_DayBarData>[];

    if (_timeframe == ChartTimeframe.thisWeek) {
      // Monday of current week
      final monday = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        final label = dayLabels[i];
        double income = 0;
        double expense = 0;

        for (final tx in widget.transactions) {
          try {
            final txDate = tx.parsedDate;
            if (txDate.year == day.year &&
                txDate.month == day.month &&
                txDate.day == day.day) {
              if (tx.isExpense) {
                expense += tx.amount;
              } else {
                income += tx.amount;
              }
            }
          } catch (_) {}
        }
        days.add(_DayBarData(
          label: label,
          income: income,
          expense: expense,
          date: day,
          isToday: day.year == now.year && day.month == now.month && day.day == now.day,
        ));
      }
    } else if (_timeframe == ChartTimeframe.last7Days) {
      // Rolling 7 days up to today
      final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 6; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final label = dayLabels[day.weekday - 1];
        double income = 0;
        double expense = 0;

        for (final tx in widget.transactions) {
          try {
            final txDate = tx.parsedDate;
            if (txDate.year == day.year &&
                txDate.month == day.month &&
                txDate.day == day.day) {
              if (tx.isExpense) {
                expense += tx.amount;
              } else {
                income += tx.amount;
              }
            }
          } catch (_) {}
        }
        days.add(_DayBarData(
          label: label,
          income: income,
          expense: expense,
          date: day,
          isToday: i == 0,
        ));
      }
    } else {
      // This Month (weekly segments W1, W2, W3, W4, W5)
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final weekCount = (daysInMonth / 7).ceil();

      for (int w = 1; w <= weekCount; w++) {
        final startDay = (w - 1) * 7 + 1;
        final endDay = math.min(w * 7, daysInMonth);
        final label = 'W$w';
        double income = 0;
        double expense = 0;

        for (final tx in widget.transactions) {
          try {
            final txDate = tx.parsedDate;
            if (txDate.year == now.year &&
                txDate.month == now.month &&
                txDate.day >= startDay &&
                txDate.day <= endDay) {
              if (tx.isExpense) {
                expense += tx.amount;
              } else {
                income += tx.amount;
              }
            }
          } catch (_) {}
        }

        final isCurrentWeek = now.day >= startDay && now.day <= endDay;
        days.add(_DayBarData(
          label: label,
          income: income,
          expense: expense,
          date: DateTime(now.year, now.month, startDay),
          isToday: isCurrentWeek,
        ));
      }
    }

    return days;
  }

  List<_CategorySlice> get _categorySlices {
    final totals = <String, double>{};
    for (final tx in widget.transactions) {
      if (tx.isExpense) {
        totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
      }
    }

    const palette = [
      AppColors.primaryPink,
      AppColors.primaryBlue,
      AppColors.successGreen,
      AppColors.shoppingOrange,
      AppColors.purple,
      Color(0xFF06B6D4),
    ];

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(6).toList().asMap().entries.map((e) {
      return _CategorySlice(
        label: e.value.key,
        amount: e.value.value,
        color: palette[e.key % palette.length],
      );
    }).toList();
  }

  double get _savingsProgress {
    if (widget.goals.isEmpty) return 0;
    final current = widget.goals.fold(0.0, (s, g) => s + g.currentAmount);
    final target = widget.goals.fold(0.0, (s, g) => s + g.targetAmount);
    if (target <= 0) return 0;
    return (current / target).clamp(0.0, 1.0);
  }

  String get _subtitleForTimeframe {
    switch (_timeframe) {
      case ChartTimeframe.thisWeek:
        return 'Current week (Mon - Sun)';
      case ChartTimeframe.last7Days:
        return 'Last 7 days activity';
      case ChartTimeframe.thisMonth:
        return 'Current month overview';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Financial Overview',
          subtitle: _subtitleForTimeframe,
          timeframe: _timeframe,
          onTimeframeChanged: (tf) {
            setState(() {
              _timeframe = tf;
              _selectedBarIndex = -1;
            });
            _animCtrl.reset();
            _animCtrl.forward();
          },
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // 1. Weekly Bar Chart
        _WeeklyBarChart(
          data: _weeklyData,
          totalTransactionsCount: widget.transactions.length,
          timeframe: _timeframe,
          progress: _anim,
          selectedIndex: _selectedBarIndex,
          onBarTapped: (i) => setState(() {
            _selectedBarIndex = _selectedBarIndex == i ? -1 : i;
          }),
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        // 2. Bottom row: Category Donut + Savings Ring
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _CategoryDonutChart(
                slices: _categorySlices,
                progress: _anim,
                selectedIndex: _selectedDonutIndex,
                onSliceTapped: (i) => setState(() {
                  _selectedDonutIndex = _selectedDonutIndex == i ? -1 : i;
                }),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _SavingsRingCard(
                progress: _savingsProgress,
                anim: _anim,
                goals: widget.goals,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final ChartTimeframe timeframe;
  final ValueChanged<ChartTimeframe> onTimeframeChanged;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.timeframe,
    required this.onTimeframeChanged,
    required this.isDark,
  });

  String get _timeframeLabel {
    switch (timeframe) {
      case ChartTimeframe.thisWeek:
        return 'This Week';
      case ChartTimeframe.last7Days:
        return 'Last 7 Days';
      case ChartTimeframe.thisMonth:
        return 'This Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        PopupMenuButton<ChartTimeframe>(
          initialValue: timeframe,
          onSelected: onTimeframeChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isDark ? AppColors.darkSurface : Colors.white,
          elevation: 6,
          itemBuilder: (context) => [
            _buildMenuItem(ChartTimeframe.thisWeek, 'This Week (Mon-Sun)'),
            _buildMenuItem(ChartTimeframe.last7Days, 'Last 7 Days'),
            _buildMenuItem(ChartTimeframe.thisMonth, 'This Month'),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeframeLabel,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<ChartTimeframe> _buildMenuItem(
      ChartTimeframe value, String title) {
    final isSelected = timeframe == value;
    return PopupMenuItem<ChartTimeframe>(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isSelected ? AppColors.primaryBlue : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryBlue : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Bar Chart
// ─────────────────────────────────────────────────────────────────────────────

class _DayBarData {
  final String label;
  final double income;
  final double expense;
  final DateTime date;
  final bool isToday;

  const _DayBarData({
    required this.label,
    required this.income,
    required this.expense,
    required this.date,
    this.isToday = false,
  });
}

class _WeeklyBarChart extends StatelessWidget {
  final List<_DayBarData> data;
  final int totalTransactionsCount;
  final ChartTimeframe timeframe;
  final Animation<double> progress;
  final int selectedIndex;
  final ValueChanged<int> onBarTapped;
  final bool isDark;

  const _WeeklyBarChart({
    required this.data,
    required this.totalTransactionsCount,
    required this.timeframe,
    required this.progress,
    required this.selectedIndex,
    required this.onBarTapped,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold(0.0, (m, d) => math.max(m, math.max(d.income, d.expense)));
    final hasData = maxVal > 0;
    final totalIncome = data.fold(0.0, (s, d) => s + d.income);
    final totalExpense = data.fold(0.0, (s, d) => s + d.expense);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income vs Expenses',
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  _LegendDot(color: AppColors.successGreen, label: 'Income'),
                  const SizedBox(width: 12),
                  _LegendDot(color: AppColors.primaryPink, label: 'Expense'),
                ],
              ),
            ],
          ),

          if (hasData) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Total: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
                Text(
                  '+Rs. ${_fmt(totalIncome)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.successGreen,
                  ),
                ),
                Text(
                  '  ·  ',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
                Text(
                  '-Rs. ${_fmt(totalExpense)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPink,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),

          // Selected bar tooltip
          if (selectedIndex >= 0 && selectedIndex < data.length)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data[selectedIndex].label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.primaryBlue),
                  ),
                  const Text(' · ',
                      style: TextStyle(color: AppColors.primaryBlue)),
                  Text(
                    '↑ Rs.${_fmt(data[selectedIndex].income)}',
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '↓ Rs.${_fmt(data[selectedIndex].expense)}',
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.primaryPink,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          // Bars
          SizedBox(
            height: 145,
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(data.length, (i) {
                    final d = data[i];
                    final isSelected = selectedIndex == i;
                    final incomeH =
                        hasData ? (d.income / maxVal) * 92 * progress.value : 0.0;
                    final expenseH =
                        hasData ? (d.expense / maxVal) * 92 * progress.value : 0.0;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onBarTapped(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                    .withValues(alpha: isDark ? 0.12 : 0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _AnimatedBar(
                                        height: incomeH,
                                        color: AppColors.successGreen,
                                        isSelected: isSelected,
                                      ),
                                      const SizedBox(width: 2),
                                      _AnimatedBar(
                                        height: expenseH,
                                        color: AppColors.primaryPink,
                                        isSelected: isSelected,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                d.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: (isSelected || d.isToday)
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : (d.isToday
                                          ? AppColors.primaryBlue
                                          : (isDark
                                              ? AppColors.darkTextMuted
                                              : AppColors.textMuted)),
                                ),
                              ),
                              if (d.isToday)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          if (!hasData) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                totalTransactionsCount > 0
                    ? 'No activity recorded for this period'
                    : 'Add transactions to see your weekly chart',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _AnimatedBar extends StatelessWidget {
  final double height;
  final Color color;
  final bool isSelected;

  const _AnimatedBar({
    required this.height,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final barH = math.max(4.0, height);
    return Container(
      width: 10,
      height: barH,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.55)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryOf(context),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Donut Chart
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySlice {
  final String label;
  final double amount;
  final Color color;

  const _CategorySlice({
    required this.label,
    required this.amount,
    required this.color,
  });
}

class _CategoryDonutChart extends StatelessWidget {
  final List<_CategorySlice> slices;
  final Animation<double> progress;
  final int selectedIndex;
  final ValueChanged<int> onSliceTapped;
  final bool isDark;

  const _CategoryDonutChart({
    required this.slices,
    required this.progress,
    required this.selectedIndex,
    required this.onSliceTapped,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = slices.fold(0.0, (s, sl) => s + sl.amount);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By Category',
            style: GoogleFonts.inter(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          Center(
            child: AnimatedBuilder(
              animation: progress,
              builder: (ctx, child) {
                return GestureDetector(
                  onTapDown: (details) {
                    if (slices.isEmpty || total <= 0) return;
                    final box = ctx.findRenderObject() as RenderBox?;
                    if (box == null) return;
                    final localPos = details.localPosition;
                    final center =
                        Offset(box.size.width / 2, box.size.height / 2);
                    final dx = localPos.dx - center.dx;
                    final dy = localPos.dy - center.dy;
                    final angle =
                        ((math.atan2(dy, dx) + math.pi / 2 + math.pi * 2) %
                            (math.pi * 2));
                    double accAngle = 0;
                    for (int i = 0; i < slices.length; i++) {
                      final sweep =
                          (slices[i].amount / total) * math.pi * 2;
                      if (angle <= accAngle + sweep) {
                        onSliceTapped(i);
                        return;
                      }
                      accAngle += sweep;
                    }
                  },
                  child: CustomPaint(
                    size: const Size(130, 130),
                    painter: _DonutPainter(
                      slices: slices,
                      progress: progress.value,
                      selectedIndex: selectedIndex,
                      isDark: isDark,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          if (slices.isEmpty)
            Center(
              child: Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            )
          else
            ...slices.take(4).toList().asMap().entries.map((e) {
              final pct = total > 0 ? (e.value.amount / total * 100) : 0.0;
              final isSelected = selectedIndex == e.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: GestureDetector(
                  onTap: () => onSliceTapped(e.key),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 10 : 8,
                        height: isSelected ? 10 : 8,
                        decoration: BoxDecoration(
                          color: e.value.color,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        e.value.color.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  )
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          e.value.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? e.value.color
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                          ),
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_CategorySlice> slices;
  final double progress;
  final int selectedIndex;
  final bool isDark;

  const _DonutPainter({
    required this.slices,
    required this.progress,
    required this.selectedIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeW = 22.0;
    final total = slices.fold(0.0, (s, sl) => s + sl.amount);

    if (total == 0 || slices.isEmpty) {
      final paint = Paint()
        ..color = isDark ? AppColors.darkBorder : AppColors.border
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, paint);
      _drawCenterLabel(canvas, center, '0\ntypes');
      return;
    }

    double startAngle = -math.pi / 2;
    const gapAngle = 0.04;

    for (int i = 0; i < slices.length; i++) {
      final sweepAngle =
          (slices[i].amount / total) * math.pi * 2 * progress - gapAngle;
      if (sweepAngle <= 0) continue;

      final isSelected = selectedIndex == i;
      final paint = Paint()
        ..color = slices[i].color
        ..strokeWidth = strokeW + (isSelected ? 5.0 : 0.0)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle + gapAngle;
    }

    _drawCenterLabel(canvas, center, '${slices.length}\ntypes');
  }

  void _drawCenterLabel(Canvas canvas, Offset center, String text) {
    final parts = text.split('\n');
    final tp1 = TextPainter(
      text: TextSpan(
        text: parts[0],
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tp2 = TextPainter(
      text: TextSpan(
        text: parts.length > 1 ? parts[1] : '',
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final totalH = tp1.height + 2 + tp2.height;
    tp1.paint(
        canvas, Offset(center.dx - tp1.width / 2, center.dy - totalH / 2));
    tp2.paint(
        canvas,
        Offset(center.dx - tp2.width / 2,
            center.dy - totalH / 2 + tp1.height + 2));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress ||
      old.selectedIndex != selectedIndex ||
      old.slices.length != slices.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Savings Ring Card
// ─────────────────────────────────────────────────────────────────────────────

class _SavingsRingCard extends StatelessWidget {
  final double progress;
  final Animation<double> anim;
  final List<SavingGoalModel> goals;
  final bool isDark;

  const _SavingsRingCard({
    required this.progress,
    required this.anim,
    required this.goals,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final current = goals.fold(0.0, (s, g) => s + g.currentAmount);
    final target = goals.fold(0.0, (s, g) => s + g.targetAmount);
    final pct = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Savings',
            style: GoogleFonts.inter(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Goals Progress',
            style: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: AnimatedBuilder(
              animation: anim,
              builder: (ctx, child) => CustomPaint(
                size: const Size(110, 110),
                painter: _RingPainter(
                  progress: progress * anim.value,
                  color: AppColors.purple,
                  trackColor: isDark ? AppColors.darkBorder : AppColors.border,
                  pct: pct,
                  isDark: isDark,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          if (goals.isNotEmpty) ...[
            _StatRow(
              label: 'Saved',
              value: 'Rs.${_fmt(current)}',
              color: AppColors.purple,
              isDark: isDark,
            ),
            const SizedBox(height: 4),
            _StatRow(
              label: 'Target',
              value: 'Rs.${_fmt(target)}',
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              isDark: isDark,
            ),
          ] else
            Center(
              child: Text(
                'No goals set',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.5,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final String pct;
  final bool isDark;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.pct,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeW = 14.0;

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progress * math.pi * 2,
        false,
        Paint()
          ..shader = LinearGradient(
            colors: [color, color.withValues(alpha: 0.6)],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Centre label — pct%
    final tp1 = TextPainter(
      text: TextSpan(
        text: '$pct%',
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tp2 = TextPainter(
      text: TextSpan(
        text: 'saved',
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final totalH = tp1.height + 2 + tp2.height;
    tp1.paint(
        canvas, Offset(center.dx - tp1.width / 2, center.dy - totalH / 2));
    tp2.paint(
        canvas,
        Offset(center.dx - tp2.width / 2,
            center.dy - totalH / 2 + tp1.height + 2));
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.pct != pct;
}
