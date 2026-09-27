import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/report_chart_models.dart';
import 'painters/cash_flow_curve_painter.dart';

/// Smooth Area & Spline Trend Card representing cumulative net cash balance over time.
class CashFlowTrendCard extends StatefulWidget {
  final List<CashFlowTrendPoint> trendPoints;
  final String period;
  final String netSavings;

  const CashFlowTrendCard({
    super.key,
    required this.trendPoints,
    this.period = 'Weekly',
    this.netSavings = '+Rs. 3,850',
  });

  @override
  State<CashFlowTrendCard> createState() => _CashFlowTrendCardState();
}

class _CashFlowTrendCardState extends State<CashFlowTrendCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _curveAnim;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _curveAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant CashFlowTrendCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _hoveredIndex = null;
      _animCtrl.reset();
      _animCtrl.forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    final selected = _hoveredIndex != null && _hoveredIndex! < widget.trendPoints.length
        ? widget.trendPoints[_hoveredIndex!]
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Cash Flow Trajectory',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Accumulated savings curve over ${widget.period.toLowerCase()}',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  selected != null
                      ? 'Rs. ${selected.value.toInt()}'
                      : widget.netSavings,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Interactive Spline Chart Area
          SizedBox(
            height: 160,
            child: AnimatedBuilder(
              animation: _curveAnim,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        _handleTouch(details.localPosition.dx, constraints.maxWidth);
                      },
                      onHorizontalDragUpdate: (details) {
                        _handleTouch(details.localPosition.dx, constraints.maxWidth);
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: CashFlowCurvePainter(
                          points: widget.trendPoints,
                          lineColor: AppColors.primaryBlue,
                          gradientStartColor: AppColors.primaryBlue.withValues(
                            alpha: isDark ? 0.35 : 0.22,
                          ),
                          gridColor: isDark
                              ? const Color(0xFF334155).withValues(alpha: 0.6)
                              : const Color(0xFFE2E8F0),
                          selectedIndex: _hoveredIndex,
                          animationProgress: _curveAnim.value,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // X-Axis Labels Row
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.trendPoints.length, (i) {
                final pt = widget.trendPoints[i];
                final isSelected = _hoveredIndex == i;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _hoveredIndex = isSelected ? null : i);
                  },
                  child: Text(
                    pt.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryBlue : textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTouch(double localX, double totalWidth) {
    if (widget.trendPoints.length < 2) return;
    final step = totalWidth / (widget.trendPoints.length - 1);
    final rawIndex = (localX / step).round();
    final clamped = rawIndex.clamp(0, widget.trendPoints.length - 1);
    if (_hoveredIndex != clamped) {
      HapticFeedback.selectionClick();
      setState(() => _hoveredIndex = clamped);
    }
  }
}
