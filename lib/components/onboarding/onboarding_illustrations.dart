import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Professional vector illustration for Onboarding Screen 1:
/// "Track Your Expenses" - 3D Blue Wallet with floating cards, golden coins,
/// PennyPal signature sprout, and pastel bubbles.
class WalletExpenseIllustration extends StatelessWidget {
  const WalletExpenseIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(
        painter: _WalletPainter(),
      ),
    );
  }
}

class _WalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.52);

    // 1. Soft Ambient Halo Glow
    final haloPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFE0E7FF),
          Color(0xFFEDE9FE),
          Colors.transparent,
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 120));
    canvas.drawCircle(center, 115, haloPaint);

    // 2. Floating soft pastel background bubbles
    final bubblePaint = Paint()..style = PaintingStyle.fill;

    bubblePaint.color = const Color(0xFFC7D2FE).withValues(alpha: 0.45);
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.28), 16, bubblePaint);

    bubblePaint.color = const Color(0xFFFBCFE8).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.32), 12, bubblePaint);

    bubblePaint.color = const Color(0xFFBAE6FD).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.72), 14, bubblePaint);

    // 3. Signature PennyPal Green Sprout (Behind Wallet)
    _drawSprout(canvas, Offset(center.dx - 45, center.dy - 65));

    // 4. Floating Credit Card Peeking Out
    _drawCreditCard(canvas, Offset(center.dx - 10, center.dy - 40));

    // 5. Main 3D Blue Wallet Body
    _drawWallet(canvas, center);

    // 6. Shiny Gold Coins (Stacked and Floating)
    _drawGoldCoin(canvas, Offset(center.dx + 65, center.dy + 35), radius: 17, hasStar: true);
    _drawGoldCoin(canvas, Offset(center.dx + 52, center.dy + 52), radius: 18, hasStar: false);
    _drawGoldCoin(canvas, Offset(center.dx + 74, center.dy + 56), radius: 16, hasStar: false);
    _drawGoldCoin(canvas, Offset(center.dx - 62, center.dy + 48), radius: 15, hasStar: true);

    // 7. Sparkle Stars
    _drawSparkle(canvas, Offset(size.width * 0.26, size.height * 0.22), 7, const Color(0xFFFFB703));
    _drawSparkle(canvas, Offset(size.width * 0.82, size.height * 0.22), 6, const Color(0xFF4361EE));
    _drawSparkle(canvas, Offset(size.width * 0.16, size.height * 0.65), 5, const Color(0xFFFF477E));
  }

  void _drawSprout(Canvas canvas, Offset origin) {
    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(origin.dx, origin.dy + 25)
      ..quadraticBezierTo(origin.dx - 4, origin.dy + 10, origin.dx - 2, origin.dy);
    canvas.drawPath(stemPath, stemPaint);

    // Left Leaf
    final leafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(origin.dx - 24, origin.dy - 12, 24, 18))
      ..style = PaintingStyle.fill;

    final leftLeaf = Path()
      ..moveTo(origin.dx - 2, origin.dy + 4)
      ..cubicTo(origin.dx - 12, origin.dy + 8, origin.dx - 24, origin.dy, origin.dx - 18, origin.dy - 8)
      ..cubicTo(origin.dx - 8, origin.dy - 12, origin.dx - 2, origin.dy - 4, origin.dx - 2, origin.dy + 4);
    canvas.drawPath(leftLeaf, leafPaint);

    // Right Leaf
    final rightLeaf = Path()
      ..moveTo(origin.dx - 2, origin.dy + 2)
      ..cubicTo(origin.dx + 8, origin.dy + 6, origin.dx + 20, origin.dy - 2, origin.dx + 16, origin.dy - 10)
      ..cubicTo(origin.dx + 6, origin.dy - 14, origin.dx, origin.dy - 4, origin.dx - 2, origin.dy + 2);
    canvas.drawPath(rightLeaf, leafPaint);
  }

  void _drawCreditCard(Canvas canvas, Offset origin) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(-0.16); // subtle tilt

    final cardRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-48, -28, 96, 56),
      const Radius.circular(10),
    );

    // Card Gradient (Pink/Rose to Indigo)
    final cardPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF5D8F), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(cardRect.outerRect);

    // Subtle drop shadow
    canvas.drawRRect(
      cardRect.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0xFF7C3AED).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawRRect(cardRect, cardPaint);

    // Chip
    final chipRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-36, -8, 14, 11),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(chipRect, Paint()..color = const Color(0xFFFDE68A));

    // Card lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-16, -4), const Offset(28, -4), linePaint);
    canvas.drawLine(const Offset(-36, 12), const Offset(14, 12), linePaint);

    canvas.restore();
  }

  void _drawWallet(Canvas canvas, Offset center) {
    final walletWidth = 148.0;
    final walletHeight = 104.0;
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - 6, center.dy + 6), width: walletWidth, height: walletHeight),
      const Radius.circular(22),
    );

    // 1. Wallet Drop Shadow
    canvas.drawRRect(
      walletRect.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0xFF0369A1).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // 2. Base Wallet Gradient (Vibrant Cyan-Blue)
    final walletPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF38BDF8),
          Color(0xFF0284C7),
          Color(0xFF0369A1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(walletRect.outerRect);
    canvas.drawRRect(walletRect, walletPaint);

    // 3. Highlight gloss at top edge
    final highlightPath = Path()
      ..moveTo(walletRect.left + 16, walletRect.top + 3)
      ..lineTo(walletRect.right - 16, walletRect.top + 3);
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // 4. Overlapping Curved Flap
    final flapPath = Path();
    final flapTop = walletRect.top + 16;
    final flapHeight = 52.0;

    flapPath.moveTo(walletRect.left, flapTop);
    flapPath.lineTo(walletRect.left + 82, flapTop);
    flapPath.cubicTo(
      walletRect.left + 104, flapTop,
      walletRect.left + 104, flapTop + flapHeight,
      walletRect.left + 82, flapTop + flapHeight,
    );
    flapPath.lineTo(walletRect.left, flapTop + flapHeight);
    flapPath.close();

    // Flap shadow
    canvas.drawPath(
      flapPath.shift(const Offset(2, 4)),
      Paint()
        ..color = const Color(0xFF075985).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Flap fill
    final flapPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0EA5E9),
          Color(0xFF0284C7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(flapPath.getBounds());
    canvas.drawPath(flapPath, flapPaint);

    // 5. Metallic Clasp Button on Flap
    final claspCenter = Offset(walletRect.left + 78, flapTop + flapHeight * 0.5);

    // Gold Outer Clasp Ring
    canvas.drawCircle(
      claspCenter,
      9,
      Paint()..color = const Color(0xFFF59E0B),
    );
    // Gold Inner Clasp
    canvas.drawCircle(
      claspCenter,
      7,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: claspCenter, radius: 7)),
    );
    // Button Center Hole
    canvas.drawCircle(
      claspCenter,
      2.5,
      Paint()..color = const Color(0xFFB45309),
    );
  }

  void _drawGoldCoin(Canvas canvas, Offset center, {required double radius, required bool hasStar}) {
    // Drop shadow
    canvas.drawCircle(
      center.translate(0, 3),
      radius,
      Paint()
        ..color = const Color(0xFFD97706).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Outer rim
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerPaint);

    // Inner rim
    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFFBBF24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.8));
    canvas.drawCircle(center, radius * 0.8, innerPaint);

    // Inner Star or Dollar sign
    if (hasStar) {
      _drawSparkle(canvas, center, radius * 0.42, const Color(0xFFB45309));
    } else {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '\$',
          style: TextStyle(
            color: const Color(0xFFB45309),
            fontSize: radius * 0.9,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width * 0.5, center.dy - textPainter.height * 0.5),
      );
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Professional vector illustration for Onboarding Screen 2:
/// "Set Your Budget" - 3D Financial Analytics Bar Chart with ascending
/// growth curve arrow, coin stacks, and plant leaf accents.
class BudgetChartIllustration extends StatelessWidget {
  const BudgetChartIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(
        painter: _ChartPainter(),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.52);

    // 1. Soft Ambient Halo Glow (Sky/Mint/Purple)
    final haloPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFE0F2FE),
          Color(0xFFF3E8FF),
          Colors.transparent,
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 120));
    canvas.drawCircle(center, 115, haloPaint);

    // 2. Translucent background bubbles
    final bubblePaint = Paint()..style = PaintingStyle.fill;
    bubblePaint.color = const Color(0xFFBAE6FD).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.3), 14, bubblePaint);

    bubblePaint.color = const Color(0xFFDDD6FE).withValues(alpha: 0.45);
    canvas.drawCircle(Offset(size.width * 0.84, size.height * 0.65), 16, bubblePaint);

    // 3. Sprout Leaves flanking chart
    _drawLeaves(canvas, Offset(size.width * 0.85, size.height * 0.4));
    _drawLeaves(canvas, Offset(size.width * 0.15, size.height * 0.65), flip: true);

    // 4. Subtle background baseline grid
    final baselineY = center.dy + 48;
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(center.dx - 85, baselineY), Offset(center.dx + 85, baselineY), gridPaint);
    canvas.drawLine(Offset(center.dx - 85, baselineY - 40), Offset(center.dx + 85, baselineY - 40), gridPaint..color = const Color(0xFFE2E8F0).withValues(alpha: 0.5));
    canvas.drawLine(Offset(center.dx - 85, baselineY - 80), Offset(center.dx + 85, baselineY - 80), gridPaint);

    // 5. 3D Rounded Bar Charts
    final bars = [
      _BarData(xOffset: -60, height: 42, colors: [const Color(0xFF818CF8), const Color(0xFF4F46E5)]),
      _BarData(xOffset: -28, height: 68, colors: [const Color(0xFF38BDF8), const Color(0xFF0284C7)]),
      _BarData(xOffset: 4, height: 55, colors: [const Color(0xFFA855F7), const Color(0xFF7E22CE)]),
      _BarData(xOffset: 36, height: 95, colors: [const Color(0xFF4361EE), const Color(0xFF312E81)]),
      _BarData(xOffset: 68, height: 116, colors: [const Color(0xFF34D399), const Color(0xFF059669)]),
    ];

    for (final bar in bars) {
      _drawBar(canvas, center.dx + bar.xOffset, baselineY, 19, bar.height, bar.colors);
    }

    // 6. Upward Trending Zigzag Line with Arrow
    _drawGrowthArrow(canvas, [
      Offset(center.dx - 60, baselineY - 48),
      Offset(center.dx - 28, baselineY - 76),
      Offset(center.dx + 4, baselineY - 64),
      Offset(center.dx + 36, baselineY - 104),
      Offset(center.dx + 68, baselineY - 128),
      Offset(center.dx + 84, baselineY - 142),
    ]);

    // 7. Golden Coins Stacks at Chart Baseline
    _drawCoin(canvas, Offset(center.dx - 55, baselineY + 12), radius: 13);
    _drawCoin(canvas, Offset(center.dx - 55, baselineY + 2), radius: 13);

    _drawCoin(canvas, Offset(center.dx + 52, baselineY + 14), radius: 14);
    _drawCoin(canvas, Offset(center.dx + 52, baselineY + 4), radius: 14);
    _drawCoin(canvas, Offset(center.dx + 52, baselineY - 6), radius: 14);

    // 8. Sparkles
    _drawSparkle(canvas, Offset(size.width * 0.28, size.height * 0.18), 7, const Color(0xFFFFB703));
    _drawSparkle(canvas, Offset(size.width * 0.88, size.height * 0.22), 8, const Color(0xFFFF477E));
  }

  void _drawBar(Canvas canvas, double x, double baselineY, double width, double height, List<Color> colors) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - width * 0.5, baselineY - height, width, height),
      const Radius.circular(8),
    );

    // Drop shadow
    canvas.drawRRect(
      rect.shift(const Offset(0, 4)),
      Paint()
        ..color = colors.last.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Gradient fill
    final barPaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect.outerRect);
    canvas.drawRRect(rect, barPaint);

    // Top glossy highlight cap
    final topCap = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - width * 0.5 + 2, baselineY - height + 2, width - 4, 6),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      topCap,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  void _drawGrowthArrow(Canvas canvas, List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Shadow
    canvas.drawPath(
      path.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0xFFFF477E).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Main vibrant stroke
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF758F),
          Color(0xFFFF477E),
          Color(0xFFFA2E69),
        ],
      ).createShader(path.getBounds())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Arrowhead at the tip
    final tip = points.last;
    final prev = points[points.length - 2];
    final angle = math.atan2(tip.dy - prev.dy, tip.dx - prev.dx);

    final arrowPath = Path();
    final arrowLength = 12.0;
    arrowPath.moveTo(tip.dx, tip.dy);
    arrowPath.lineTo(
      tip.dx - arrowLength * math.cos(angle - math.pi / 6),
      tip.dy - arrowLength * math.sin(angle - math.pi / 6),
    );
    arrowPath.lineTo(
      tip.dx - arrowLength * 0.6 * math.cos(angle),
      tip.dy - arrowLength * 0.6 * math.sin(angle),
    );
    arrowPath.lineTo(
      tip.dx - arrowLength * math.cos(angle + math.pi / 6),
      tip.dy - arrowLength * math.sin(angle + math.pi / 6),
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, Paint()..color = const Color(0xFFFA2E69));

    // Data node points
    for (final pt in points.take(points.length - 1)) {
      canvas.drawCircle(pt, 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(pt, 2.8, Paint()..color = const Color(0xFFFF477E));
    }
  }

  void _drawLeaves(Canvas canvas, Offset origin, {bool flip = false}) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    if (flip) canvas.scale(-1, 1);

    final leafPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(10, -10, 22, -6, 20, 10)
      ..cubicTo(14, 16, 4, 10, 0, 0);

    final leafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(0, -10, 22, 26));

    canvas.drawPath(leafPath, leafPaint);
    canvas.restore();
  }

  void _drawCoin(Canvas canvas, Offset center, {required double radius}) {
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerPaint);

    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFFBBF24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.78));
    canvas.drawCircle(center, radius * 0.78, innerPaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarData {
  final double xOffset;
  final double height;
  final List<Color> colors;

  _BarData({required this.xOffset, required this.height, required this.colors});
}

/// Professional vector illustration for Onboarding Screen 3:
/// "Save for Your Dreams" - Adorable 3D Pink Piggy Bank with coin dropping
/// into the slot, gold coin stacks, and festive sparkles.
class PiggyBankIllustration extends StatelessWidget {
  const PiggyBankIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(
        painter: _PiggyPainter(),
      ),
    );
  }
}

class _PiggyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.48, size.height * 0.54);

    // 1. Soft Ambient Halo Glow (Pink/Rose)
    final haloPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFCE7F3),
          Color(0xFFF3E8FF),
          Colors.transparent,
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 120));
    canvas.drawCircle(center, 115, haloPaint);

    // 2. Translucent bubbles
    final bubblePaint = Paint()..style = PaintingStyle.fill;
    bubblePaint.color = const Color(0xFFFBCFE8).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(size.width * 0.16, size.height * 0.35), 15, bubblePaint);

    bubblePaint.color = const Color(0xFFDDD6FE).withValues(alpha: 0.45);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.38), 13, bubblePaint);

    // 3. Little curly tail (Behind pig on left)
    _drawTail(canvas, Offset(center.dx - 62, center.dy));

    // 4. Little feet
    _drawFoot(canvas, Offset(center.dx - 38, center.dy + 45));
    _drawFoot(canvas, Offset(center.dx - 14, center.dy + 45));
    _drawFoot(canvas, Offset(center.dx + 22, center.dy + 45));
    _drawFoot(canvas, Offset(center.dx + 44, center.dy + 45));

    // 5. Main Pig Body
    _drawPigBody(canvas, center);

    // 6. Cute Ears
    _drawEar(canvas, Offset(center.dx - 28, center.dy - 44), isLeft: true);
    _drawEar(canvas, Offset(center.dx + 24, center.dy - 46), isLeft: false);

    // 7. Snout & Facial details
    _drawSnoutAndFace(canvas, center);

    // 8. Top Coin Slot & Descending Gold Coin
    _drawCoinSlot(canvas, Offset(center.dx + 4, center.dy - 44));
    _drawFallingCoin(canvas, Offset(center.dx + 4, center.dy - 74));

    // 9. Side Golden Coins Stacks
    _drawCoin(canvas, Offset(center.dx + 72, center.dy + 38), radius: 14);
    _drawCoin(canvas, Offset(center.dx + 72, center.dy + 26), radius: 14);
    _drawCoin(canvas, Offset(center.dx + 60, center.dy + 46), radius: 13);
    _drawCoin(canvas, Offset(center.dx - 62, center.dy + 44), radius: 13);

    // 10. PennyPal Green Leaf Accent
    _drawLeaf(canvas, Offset(center.dx + 84, center.dy + 15));

    // 11. Golden & Pink Sparkle Stars
    _drawSparkle(canvas, Offset(size.width * 0.22, size.height * 0.22), 8, const Color(0xFFFFB703));
    _drawSparkle(canvas, Offset(size.width * 0.84, size.height * 0.22), 7, const Color(0xFFFF477E));
    _drawSparkle(canvas, Offset(size.width * 0.88, size.height * 0.58), 6, const Color(0xFF4361EE));
  }

  void _drawPigBody(Canvas canvas, Offset center) {
    final bodyRect = Rect.fromCenter(center: center, width: 124, height: 102);

    // Drop shadow
    canvas.drawOval(
      bodyRect.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0xFFBE185D).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Main 3D Gradient
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF85A1),
          Color(0xFFFF5D8F),
          Color(0xFFE11D48),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);
    canvas.drawOval(bodyRect, bodyPaint);

    // Upper highlight gloss
    final highlightRect = Rect.fromCenter(
      center: Offset(center.dx - 12, center.dy - 24),
      width: 65,
      height: 30,
    );
    canvas.drawOval(
      highlightRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(highlightRect),
    );
  }

  void _drawFoot(Canvas canvas, Offset pos) {
    final footRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pos, width: 16, height: 16),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      footRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF5D8F), Color(0xFFBE185D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(footRect.outerRect),
    );
  }

  void _drawEar(Canvas canvas, Offset pos, {required bool isLeft}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(isLeft ? -0.25 : 0.25);

    final earPath = Path()
      ..moveTo(-12, 10)
      ..quadraticBezierTo(-8, -16, 0, -22)
      ..quadraticBezierTo(14, -16, 12, 10)
      ..close();

    // Outer ear
    canvas.drawPath(
      earPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF85A1), Color(0xFFE11D48)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(earPath.getBounds()),
    );

    // Inner ear
    final innerEar = Path()
      ..moveTo(-7, 8)
      ..quadraticBezierTo(-4, -8, 0, -14)
      ..quadraticBezierTo(8, -8, 7, 8)
      ..close();

    canvas.drawPath(
      innerEar,
      Paint()..color = const Color(0xFFFFB3C1),
    );

    canvas.restore();
  }

  void _drawSnoutAndFace(Canvas canvas, Offset center) {
    // 1. Cute Eyes with shine
    final leftEye = Offset(center.dx - 22, center.dy - 12);
    final rightEye = Offset(center.dx + 26, center.dy - 12);

    for (final eye in [leftEye, rightEye]) {
      // Eye circle
      canvas.drawCircle(eye, 4.5, Paint()..color = const Color(0xFF1E293B));
      // Specular highlight
      canvas.drawCircle(Offset(eye.dx - 1.4, eye.dy - 1.4), 1.6, Paint()..color = Colors.white);
    }

    // 2. Snout (Nose)
    final snoutCenter = Offset(center.dx + 2, center.dy + 10);
    final snoutRect = Rect.fromCenter(center: snoutCenter, width: 44, height: 32);

    // Snout shadow
    canvas.drawOval(
      snoutRect.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0xFFBE185D).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Snout body
    final snoutPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFC2D1), Color(0xFFFF85A1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(snoutRect);
    canvas.drawOval(snoutRect, snoutPaint);

    // Nostrils
    canvas.drawOval(
      Rect.fromCenter(center: Offset(snoutCenter.dx - 7, snoutCenter.dy), width: 5, height: 7),
      Paint()..color = const Color(0xFFBE185D),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(snoutCenter.dx + 7, snoutCenter.dy), width: 5, height: 7),
      Paint()..color = const Color(0xFFBE185D),
    );

    // 3. Cute Blush Cheeks
    canvas.drawCircle(
      Offset(center.dx - 36, center.dy + 8),
      8,
      Paint()..color = const Color(0xFFFF3366).withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      Offset(center.dx + 40, center.dy + 8),
      8,
      Paint()..color = const Color(0xFFFF3366).withValues(alpha: 0.25),
    );
  }

  void _drawCoinSlot(Canvas canvas, Offset pos) {
    final slotRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: pos, width: 26, height: 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(slotRect, Paint()..color = const Color(0xFF9D174D));
  }

  void _drawFallingCoin(Canvas canvas, Offset center) {
    // Motion trail lines
    final trailPaint = Paint()
      ..color = const Color(0xFFFFB703).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(center.dx - 12, center.dy + 12), Offset(center.dx - 12, center.dy + 24), trailPaint);
    canvas.drawLine(Offset(center.dx + 12, center.dy + 12), Offset(center.dx + 12, center.dy + 24), trailPaint);

    // Gold coin
    final radius = 17.0;
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFFBBF24), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerPaint);

    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEF3C7), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.78));
    canvas.drawCircle(center, radius * 0.78, innerPaint);

    _drawSparkle(canvas, center, 7, const Color(0xFFB45309));
  }

  void _drawTail(Canvas canvas, Offset origin) {
    final tailPaint = Paint()
      ..color = const Color(0xFFFF5D8F)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..cubicTo(origin.dx - 14, origin.dy - 12, origin.dx - 20, origin.dy + 6, origin.dx - 10, origin.dy + 4);
    canvas.drawPath(path, tailPaint);
  }

  void _drawLeaf(Canvas canvas, Offset origin) {
    final leafPath = Path()
      ..moveTo(origin.dx, origin.dy)
      ..cubicTo(origin.dx + 8, origin.dy - 12, origin.dx + 18, origin.dy - 8, origin.dx + 14, origin.dy + 6)
      ..cubicTo(origin.dx + 8, origin.dy + 10, origin.dx + 2, origin.dy + 4, origin.dx, origin.dy);

    final leafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF059669)],
      ).createShader(leafPath.getBounds());

    canvas.drawPath(leafPath, leafPaint);
  }

  void _drawCoin(Canvas canvas, Offset center, {required double radius}) {
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerPaint);

    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFBEB), Color(0xFFFBBF24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.78));
    canvas.drawCircle(center, radius * 0.78, innerPaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
