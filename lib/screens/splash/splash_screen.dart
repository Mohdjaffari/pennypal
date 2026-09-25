import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../components/onboardscreens.dart';
import '../../HomePage.dart';

/// Professional, highly polished Splash Screen for PennyPal.
/// Features staggered entrance animations, glowing ambient orbs,
/// dynamic status updates, and smart onboarding vs dashboard routing.
class SplashScreen extends StatefulWidget {
  final bool autoNavigate;
  final Duration duration;

  const SplashScreen({
    super.key,
    this.autoNavigate = true,
    this.duration = const Duration(milliseconds: 2800),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimController;
  late AnimationController _pulseAnimController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentSlide;
  late Animation<double> _contentFade;
  late Animation<double> _pulseScale;

  Timer? _navigationTimer;
  Timer? _statusTimer;
  int _currentStatusIndex = 0;

  final List<String> _loadingStatuses = [
    'Initializing smart vault...',
    'Loading student budgets & goals...',
    'Syncing local privacy engine...',
    'Ready!',
  ];

  @override
  void initState() {
    super.initState();

    // 1. Entrance Staggered Controller (1.4 seconds)
    _mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = CurvedAnimation(
      parent: _mainAnimController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
    );

    _logoFade = CurvedAnimation(
      parent: _mainAnimController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
    );

    _contentSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _contentFade = CurvedAnimation(
      parent: _mainAnimController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeIn),
    );

    // 2. Subtle ambient pulse for the logo glow
    _pulseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
    );

    _mainAnimController.forward();

    // Status rotation timer
    _statusTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (mounted && _currentStatusIndex < _loadingStatuses.length - 1) {
        setState(() => _currentStatusIndex++);
      }
    });

    // Auto navigation timer
    if (widget.autoNavigate) {
      _navigationTimer = Timer(widget.duration, _proceedToNextScreen);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _statusTimer?.cancel();
    _mainAnimController.dispose();
    _pulseAnimController.dispose();
    super.dispose();
  }

  Future<void> _proceedToNextScreen() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    // Default to false: first time user sees onboarding
    final isNotFirstTime = prefs.getBool('isNotFirstTime') ?? false;

    if (!mounted) return;

    final Widget destination = isNotFirstTime
        ? const Homepage()
        : const OnboardingScreens();

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
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate Canvas
      body: Stack(
        children: [
          // 1. Ambient Background Glowing Orbs
          _buildAmbientGlow(
            top: -60,
            right: -50,
            color: AppColors.primaryPink.withValues(alpha: 0.28),
            size: 260,
          ),
          _buildAmbientGlow(
            bottom: 40,
            left: -70,
            color: AppColors.primaryBlue.withValues(alpha: 0.24),
            size: 280,
          ),
          _buildAmbientGlow(
            top: size.height * 0.42,
            right: -60,
            color: AppColors.purple.withValues(alpha: 0.20),
            size: 220,
          ),

          // 2. Subtle Radial Mesh Texture
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.95,
                  colors: [
                    const Color(0xFF1E293B).withValues(alpha: 0.6),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),

          // 3. Skip Button (Top Right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: TextButton(
                  onPressed: _proceedToNextScreen,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 11),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Center Brand Emblem & Title
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Animated Logo Icon
                AnimatedBuilder(
                  animation: _pulseAnimController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseScale.value,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoFade,
                          child: _buildLogoBadge(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Staggered Title & Tagline
                AnimatedBuilder(
                  animation: _mainAnimController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _contentSlide.value),
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: Column(
                          children: [
                            // App Name with Gradient Accent
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Penny',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [
                                      AppColors.primaryPink,
                                      Color(0xFFFF758F),
                                    ],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Pal',
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Tagline pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppColors.shoppingOrange,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Smart Student Budgeting Companion',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFCBD5E1),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                // 5. Dynamic Loading Status & Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      // Loading Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 4,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Animated Status Text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _loadingStatuses[_currentStatusIndex],
                          key: ValueKey<int>(_currentStatusIndex),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 6. Footer Metadata
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'PennyPal v1.0.0 • 100% Private & Local',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Logo badge with layered glassmorphism, gradient shadow & shiny coin icon
  Widget _buildLogoBadge() {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryPink,
            Color(0xFFFF5D8F),
            AppColors.purple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.45),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner glass gloss highlight
          Positioned(
            top: 4,
            left: 8,
            right: 8,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                  bottom: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Main App Icon
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 48,
          ),

          // Little Sparkle / Star on top corner
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.shoppingOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ambient blurry glowing orb widget
  Widget _buildAmbientGlow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 100,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}
