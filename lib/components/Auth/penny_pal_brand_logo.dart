import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Professional vector PennyPal brand mark with sprouting leaves & peeking card.
/// Matches the authentic identity from the design board at any scale.
class PennyPalBrandLogo extends StatelessWidget {
  final double iconSize;
  final bool showText;
  final double titleFontSize;
  final double subtitleFontSize;

  const PennyPalBrandLogo({
    super.key,
    this.iconSize = 58,
    this.showText = true,
    this.titleFontSize = 24,
    this.subtitleFontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sprout + Peeking Card + Wallet Icon Mark
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _PennyPalEmblemPainter(),
          ),
        ),

        if (showText) ...[
          const SizedBox(height: 10),
          // App Title — Two-Tone Penny (Blue) + Pal (Pink)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Penny',
                  style: GoogleFonts.inter(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                    letterSpacing: -0.6,
                  ),
                ),
                TextSpan(
                  text: 'Pal',
                  style: GoogleFonts.inter(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPink,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          // Subtitle Tagline
          Text(
            'Fresh All Along',
            style: GoogleFonts.inter(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryOf(context),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _PennyPalEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sprout at top (organic stem + 2 vibrant leaves)
    _drawSprout(canvas, Offset(w * 0.52, h * 0.30), w);

    // 2. Peeking Credit Card (White card with pink stripe peeking behind the wallet flap)
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.32, w * 0.56, h * 0.30),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      cardRect,
      Paint()..color = const Color(0xFFF1F5F9),
    );
    // Card pink stripe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.36, w * 0.48, h * 0.08),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFF477E),
    );

    // 3. Wallet Body
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.65),
        width: w * 0.74,
        height: h * 0.50,
      ),
      const Radius.circular(12),
    );

    // Wallet Drop Shadow
    canvas.drawRRect(
      walletRect.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0xFF1E40AF).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Wallet Base Gradient (Vibrant Cyan-Blue matching mockup)
    final walletPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF38BDF8), // Sky Cyan
          Color(0xFF2563EB), // Royal Blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(walletRect.outerRect);
    canvas.drawRRect(walletRect, walletPaint);

    // Inner Gloss Highlight on top of wallet
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        walletRect.left + 2,
        walletRect.top + 2,
        walletRect.width - 4,
        walletRect.height * 0.28,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      highlightRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(highlightRect.outerRect),
    );

    // Wallet Horizontal Stitching / Flap Division
    final flapPath = Path()
      ..moveTo(walletRect.left, walletRect.top + walletRect.height * 0.42)
      ..lineTo(walletRect.right, walletRect.top + walletRect.height * 0.42);
    canvas.drawPath(
      flapPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );

    // Front Clasp Strap (Right-centered)
    final claspRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(walletRect.right - 5, walletRect.top + walletRect.height * 0.58),
        width: 16,
        height: 14,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      claspRect,
      Paint()..color = const Color(0xFF1D4ED8),
    );

    // Vibrant Pink Clasp Dot
    canvas.drawCircle(
      Offset(walletRect.right - 5, walletRect.top + walletRect.height * 0.58),
      4.0,
      Paint()..color = const Color(0xFFFF3B70),
    );

    // Clasp Highlight
    canvas.drawCircle(
      Offset(walletRect.right - 5.8, walletRect.top + walletRect.height * 0.56),
      1.4,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
  }

  void _drawSprout(Canvas canvas, Offset origin, double w) {
    // Sprout Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(origin.dx, origin.dy + 8)
      ..quadraticBezierTo(origin.dx - 3, origin.dy - 2, origin.dx, origin.dy - 10);
    canvas.drawPath(stemPath, stemPaint);

    // Left Sprout Leaf
    final leftLeafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(origin.dx - 16, origin.dy - 16, 18, 14))
      ..style = PaintingStyle.fill;

    final leftLeaf = Path()
      ..moveTo(origin.dx - 1, origin.dy - 4)
      ..cubicTo(origin.dx - 8, origin.dy - 2, origin.dx - 16, origin.dy - 8, origin.dx - 12, origin.dy - 15)
      ..cubicTo(origin.dx - 5, origin.dy - 16, origin.dx - 1, origin.dy - 8, origin.dx - 1, origin.dy - 4);
    canvas.drawPath(leftLeaf, leftLeafPaint);

    // Right Sprout Leaf
    final rightLeafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF34D399), Color(0xFF047857)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(origin.dx, origin.dy - 18, 18, 14))
      ..style = PaintingStyle.fill;

    final rightLeaf = Path()
      ..moveTo(origin.dx, origin.dy - 6)
      ..cubicTo(origin.dx + 7, origin.dy - 3, origin.dx + 15, origin.dy - 10, origin.dx + 12, origin.dy - 17)
      ..cubicTo(origin.dx + 4, origin.dy - 17, origin.dx, origin.dy - 10, origin.dx, origin.dy - 6);
    canvas.drawPath(rightLeaf, rightLeafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
