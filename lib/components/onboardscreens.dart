import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../HomePage.dart';
import 'onboarding/onboarding_model.dart';
import 'onboarding/onboarding_page_item.dart';

/// Professional, pixel-perfect Onboarding Flow for PennyPal.
/// Exactly follows the design mockup:
/// - Screen 1: "Track Your Expenses" (Wallet & Sprout) + Blue "Next"
/// - Screen 2: "Set Your Budget" (Analytics Chart) + Blue "Next"
/// - Screen 3: "Save for Your Dreams" (Pink Piggy Bank) + Vibrant Pink "Get Started"
class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  final List<OnboardingModel> _pages = OnboardingModel.screens;
  int _currentIndex = 0;

  bool get _isLastPage => _currentIndex == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotFirstTime', true);

    if (!mounted) return;

    // After onboarding, navigate directly to Homepage (in Guest mode if not logged in)
    const Widget targetScreen = Homepage();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onNextPressed() {
    HapticFeedback.selectionClick();
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onSkipPressed() {
    HapticFeedback.selectionClick();
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.animateToPage(
        _pages.length - 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isLastPage ? AppColors.primaryPink : AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: TextButton(
              onPressed: _onSkipPressed,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                splashFactory: InkRipple.splashFactory,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                _isLastPage ? 'Get Started' : 'Skip',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Swipable Hero Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPageItem(item: _pages[index]);
                },
              ),
            ),

            // 2. Pagination Indicator (Expanding active pill)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 6.5,
                  dotWidth: 6.5,
                  expansionFactor: 3.6,
                  spacing: 6.0,
                  dotColor: Color(0xFFE2E8F0),
                  activeDotColor: AppColors.primaryPink,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeInOutCubic,
                  );
                },
              ),
            ),

            // 3. Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _isLastPage ? 'Get Started' : 'Next',
                        key: ValueKey<bool>(_isLastPage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
