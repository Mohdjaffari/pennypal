import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/onboardscreens.dart';
import '../../HomePage.dart';

/// Professional Splash Screen for PennyPal.
/// Accurately matches the official brand design:
///   - Top Wallet with vibrant green sprout emblem
///   - Two-tone "Penny" (Blue) & "Pal" (Pink) wordmark
///   - "Fresh All Along" brand tagline
///   - High-fidelity student finance illustration
///   - Dual-curved organic bottom waves (Pink & Blue)
///   - Centered "Smart Money • Better Future" footer slogan
///   - Smooth staggered entrance & gentle floating micro-animations
///   - Smart first-time user onboarding routing vs. dashboard routing
class SplashScreen extends StatefulWidget {
  final bool autoNavigate;
  final Duration duration;

  const SplashScreen({
    super.key,
    this.autoNavigate = true,
    this.duration = const Duration(milliseconds: 2700),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation Controllers ──────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final AnimationController _floatingCtrl;

  // Staggered Entrance Animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _illustrationScale;
  late final Animation<double> _illustrationFade;
  late final Animation<Offset> _waveSlide;
  late final Animation<double> _footerFade;

  // Ambient Floating Animation for the Hero Illustration
  late final Animation<double> _floatAnim;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Controller (1200ms)
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.20, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.20, 0.55, curve: Curves.easeIn),
    );

    _illustrationScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _illustrationFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
    );

    _waveSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.15, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _footerFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.50, 0.95, curve: Curves.easeIn),
    );

    // 2. Gentle Floating Loop for Hero Character (2.4s period)
    _floatingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -3.5, end: 3.5).animate(
      CurvedAnimation(parent: _floatingCtrl, curve: Curves.easeInOut),
    );

    // Start entrance
    _entranceCtrl.forward();

    // Auto navigation
    if (widget.autoNavigate) {
      _navigationTimer = Timer(widget.duration, _proceedToNextScreen);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceCtrl.dispose();
    _floatingCtrl.dispose();
    super.dispose();
  }

  Future<void> _proceedToNextScreen() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    // Default: false -> onboarding screens for new installs
    final isNotFirstTime = prefs.getBool('isNotFirstTime') ?? false;

    if (!mounted) return;

    final Widget destination =
        isNotFirstTime ? const Homepage() : const OnboardingScreens();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use clean bright canvas matching the reference mockup
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFD);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () {
          // If in replay mode or user taps, advance immediately
          if (!widget.autoNavigate) {
            Navigator.of(context).maybePop();
          } else {
            _navigationTimer?.cancel();
            _proceedToNextScreen();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // ── 1. Soft Ambient Radial Glow at Top Center ────────────────────
            Positioned(
              top: -60,
              left: size.width * 0.15,
              right: size.width * 0.15,
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.15 : 0.12),
                      const Color(0xFF60A5FA).withValues(alpha: isDark ? 0.08 : 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── 2. Replay Close Button (when opened manually) ────────────────
            if (!widget.autoNavigate)
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          size: 18,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
              ),

            // ── 3. Main Brand & Hero Content ─────────────────────────────────
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Brand Emblem (Wallet + Sprout)
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: const _PennyPalWalletSprout(size: 68),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Brand Wordmark & Tagline
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // "PennyPal" Two-Tone Title
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Penny',
                                  style: GoogleFonts.inter(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1D4ED8), // Royal Blue
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Pal',
                                  style: GoogleFonts.inter(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFF43F5E), // Vibrant Pink/Rose
                                    letterSpacing: -0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 5),

                          // "Fresh All Along" Tagline
                          Text(
                            'Fresh All Along',
                            style: GoogleFonts.inter(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF1E293B),
                              letterSpacing: 0.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Hero Illustration (Floating Character with Books & Coins)
                  Expanded(
                    child: ScaleTransition(
                      scale: _illustrationScale,
                      child: FadeTransition(
                        opacity: _illustrationFade,
                        child: AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnim.value),
                              child: child,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Center(
                              child: _buildHeroIllustration(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Spacing above the wave
                  SizedBox(height: size.height * 0.15),
                ],
              ),
            ),

            // ── 4. Bottom Double Wave & Tagline Footer ────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _waveSlide,
                child: SizedBox(
                  height: size.height * 0.22,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Dual Wave CustomPainter (Pink & Royal Blue)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SplashDualWavePainter(),
                        ),
                      ),

                      // Centered Footer Slogan: "Smart Money • Better Future"
                      FadeTransition(
                        opacity: _footerFade,
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 22.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Smart Money',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                                  child: Container(
                                    width: 4.5,
                                    height: 4.5,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Better Future',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the hero illustration with asset fallback and smooth presentation.
  Widget _buildHeroIllustration() {
    return Image.asset(
      'assets/images/splash_illustration.jpg',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // High-fidelity fallback vector if asset is loading or missing
        return Container(
          width: 280,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.school_rounded, color: Color(0xFF2563EB), size: 54),
              SizedBox(height: 10),
              Text(
                'PennyPal Student Finance',
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. PennyPal Wallet with Sprout Custom Emblem
// ─────────────────────────────────────────────────────────────────────────────

class _PennyPalWalletSprout extends StatelessWidget {
  final double size;

  const _PennyPalWalletSprout({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WalletSproutPainter(),
      ),
    );
  }
}

class _WalletSproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Top Sprout Leaves (Growth & Prosperity) ───────────────────────────
    final sproutCenter = Offset(w * 0.50, h * 0.28);

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(sproutCenter.dx, sproutCenter.dy + 8)
      ..quadraticBezierTo(sproutCenter.dx - 2, sproutCenter.dy, sproutCenter.dx, sproutCenter.dy - 10);
    canvas.drawPath(stemPath, stemPaint);

    // Left Leaf (Organic cyan/sky-blue leaf)
    final leftLeafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(sproutCenter.dx - 18, sproutCenter.dy - 18, 18, 16))
      ..style = PaintingStyle.fill;

    final leftLeaf = Path()
      ..moveTo(sproutCenter.dx - 1, sproutCenter.dy - 3)
      ..cubicTo(
        sproutCenter.dx - 8, sproutCenter.dy,
        sproutCenter.dx - 18, sproutCenter.dy - 6,
        sproutCenter.dx - 13, sproutCenter.dy - 16,
      )
      ..cubicTo(
        sproutCenter.dx - 5, sproutCenter.dy - 17,
        sproutCenter.dx - 1, sproutCenter.dy - 8,
        sproutCenter.dx - 1, sproutCenter.dy - 3,
      );
    canvas.drawPath(leftLeaf, leftLeafPaint);

    // Right Leaf
    final rightLeafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0369A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(sproutCenter.dx, sproutCenter.dy - 20, 20, 18))
      ..style = PaintingStyle.fill;

    final rightLeaf = Path()
      ..moveTo(sproutCenter.dx, sproutCenter.dy - 5)
      ..cubicTo(
        sproutCenter.dx + 8, sproutCenter.dy - 1,
        sproutCenter.dx + 18, sproutCenter.dy - 8,
        sproutCenter.dx + 14, sproutCenter.dy - 18,
      )
      ..cubicTo(
        sproutCenter.dx + 4, sproutCenter.dy - 18,
        sproutCenter.dx, sproutCenter.dy - 10,
        sproutCenter.dx, sproutCenter.dy - 5,
      );
    canvas.drawPath(rightLeaf, rightLeafPaint);

    // ── 2. Wallet Body ───────────────────────────────────────────────────────
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.65),
        width: w * 0.74,
        height: h * 0.52,
      ),
      const Radius.circular(13),
    );

    // Drop Shadow
    canvas.drawRRect(
      walletRect.shift(const Offset(0, 5)),
      Paint()
        ..color = const Color(0xFF1D4ED8).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Wallet Gradient (Vibrant Blue matching mockup)
    final walletPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF38BDF8), // Cyan
          Color(0xFF2563EB), // Royal Blue
          Color(0xFF1D4ED8), // Deep Blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(walletRect.outerRect);
    canvas.drawRRect(walletRect, walletPaint);

    // Top Gloss Highlight
    final glossRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        walletRect.left + 2,
        walletRect.top + 2,
        walletRect.width - 4,
        walletRect.height * 0.32,
      ),
      const Radius.circular(11),
    );
    canvas.drawRRect(
      glossRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(glossRect.outerRect),
    );

    // ── 3. Coral/Red Clasp with Coin Dot ────────────────────────────────────
    final claspWidth = w * 0.26;
    final claspHeight = h * 0.19;
    final claspCenter = Offset(
      walletRect.right - claspWidth * 0.45,
      walletRect.top + walletRect.height * 0.54,
    );

    final claspRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: claspCenter,
        width: claspWidth,
        height: claspHeight,
      ),
      const Radius.circular(6.5),
    );

    // Clasp Shadow
    canvas.drawRRect(
      claspRect.shift(const Offset(0, 1.5)),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Clasp Base (Vibrant Red-Pink)
    canvas.drawRRect(
      claspRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFB7185), Color(0xFFF43F5E), Color(0xFFE11D48)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(claspRect.outerRect),
    );

    // Inner White Coin/Button Dot
    final dotCenter = Offset(claspCenter.dx - claspWidth * 0.10, claspCenter.dy);
    canvas.drawCircle(
      dotCenter,
      claspHeight * 0.28,
      Paint()..color = Colors.white,
    );

    // Dot center indent
    canvas.drawCircle(
      dotCenter,
      claspHeight * 0.12,
      Paint()..color = const Color(0xFFF43F5E),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Dual-Curved Organic Bottom Wave Painter (Pink & Royal Blue)
// ─────────────────────────────────────────────────────────────────────────────

class _SplashDualWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Layer 1: Pink / Magenta Ribbon Curve (Top wave) ─────────────────────
    final pinkPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFF472B6), // Soft Pink
          Color(0xFFEC4899), // Hot Pink
          Color(0xFFFB7185), // Coral Rose
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final pinkPath = Path();
    // Starts at left at around 28% from top of wave canvas
    pinkPath.moveTo(0, h * 0.26);
    // Organic crest and trough
    pinkPath.cubicTo(
      w * 0.22, h * 0.48,
      w * 0.65, h * 0.04,
      w, h * 0.28,
    );
    pinkPath.lineTo(w, h);
    pinkPath.lineTo(0, h);
    pinkPath.close();
    canvas.drawPath(pinkPath, pinkPaint);

    // ── Layer 2: Main Royal Blue / Indigo Curve (Overlapping bottom) ────────
    final bluePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2563EB), // Royal Blue
          Color(0xFF3B82F6), // Vibrant Sky Blue
          Color(0xFF1D4ED8), // Deep Blue
          Color(0xFF4F46E5), // Indigo
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bluePath = Path();
    // Starts at left at around 44% from top of wave canvas
    bluePath.moveTo(0, h * 0.44);
    // Smooth S-curve matching the mockup
    bluePath.cubicTo(
      w * 0.32, h * 0.64,
      w * 0.68, h * 0.26,
      w, h * 0.42,
    );
    bluePath.lineTo(w, h);
    bluePath.lineTo(0, h);
    bluePath.close();
    canvas.drawPath(bluePath, bluePaint);

    // Soft top ambient highlight on the blue wave
    final waveHighlightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.35, w, 20))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final highlightPath = Path()
      ..moveTo(0, h * 0.44)
      ..cubicTo(
        w * 0.32, h * 0.64,
        w * 0.68, h * 0.26,
        w, h * 0.42,
      );
    canvas.drawPath(highlightPath, waveHighlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
