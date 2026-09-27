// ignore_for_file: file_names
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_service.dart';
import 'LoginScreen.dart';
import 'penny_pal_brand_logo.dart';

/// Professional, pixel-perfect Forgot Password Screen for PennyPal.
/// Adheres strictly to the PennyPal brand identity and visual aesthetic:
/// - PennyPal Brand Emblem & Two-Tone Typography ("Penny" Blue + "Pal" Pink)
/// - Interactive Dark/Light Theme Toggle in AppBar
/// - Clean step-based password reset workflow:
///   1. Request reset link / OTP via registered Email or Phone
///   2. Interactive 4-digit code verification + new password creation
/// - Smooth haptics, timers, and navigation back to Login
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailPhoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  final _formKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  bool _isCodeSent = false;
  bool _isLoading = false;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _isInputValid = false;

  int _resendCountdown = 45;
  Timer? _countdownTimer;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final TapGestureRecognizer _loginTap;

  @override
  void initState() {
    super.initState();

    ThemeService.instance.addListener(_handleThemeChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _emailPhoneController.addListener(() {
      final text = _emailPhoneController.text.trim();
      final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text) ||
          RegExp(r'^[+0-9\s-]{8,15}$').hasMatch(text);
      if (valid != _isInputValid) {
        setState(() => _isInputValid = valid);
      }
    });

    _loginTap = TapGestureRecognizer()..onTap = _navigateToLogin;

    _animController.forward();
  }

  void _handleThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_handleThemeChanged);
    _animController.dispose();
    _emailPhoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    _loginTap.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 45;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _navigateToLogin() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const LoginScreen(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  Future<void> _handleSendInstructions() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.vibrate();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isCodeSent = true;
    });

    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('4-digit recovery code sent successfully!'),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();

    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the complete 4-digit code'),
          backgroundColor: AppColors.expenseRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (!(_resetFormKey.currentState?.validate() ?? false)) {
      HapticFeedback.vibrate();
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: AppColors.expenseRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 750));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Password updated successfully! Please login.'),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );

    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.instance.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFD);
    final backIconBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final backIconColor = isDark ? Colors.white : const Color(0xFF334155);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: backIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: backIconColor,
                  ),
                ),
                onPressed: () {
                  if (_isCodeSent) {
                    setState(() => _isCodeSent = false);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: _isCodeSent
                            ? _buildOtpStage(isDark)
                            : _buildRequestStage(isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Initial Screen: Enter email or phone to receive OTP/reset instructions
  Widget _buildRequestStage(bool isDark) {
    final inputFill = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final inputBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. PennyPal Brand Emblem & Tagline
          const PennyPalBrandLogo(
            iconSize: 58,
            titleFontSize: 24,
            subtitleFontSize: 12.5,
          ),

          const SizedBox(height: 28),

          // 2. Titles
          Text(
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Don't worry! Enter your registered email address or phone number and we'll send a recovery code.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: subtextColor,
              ),
            ),
          ),

          const SizedBox(height: 34),

          // 3. Email or Phone Field
          TextFormField(
            controller: _emailPhoneController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your registered email or phone';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Email or Phone',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: inputFill,
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                size: 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              suffixIcon: _isInputValid
                  ? const Padding(
                      padding: EdgeInsets.only(right: 14.0),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.successGreen,
                        size: 18,
                      ),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: inputBorder,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.expenseRed,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.expenseRed,
                  width: 1.8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // 4. Send Instructions Button (PennyPal Electric Blue Gradient)
          SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.35 : 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendInstructions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Send Recovery Code',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // 5. Back to Login link
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Remember your password? ',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: subtextColor,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: 'Login',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: _loginTap,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Second Screen: Enter 4-digit code and create new password
  Widget _buildOtpStage(bool isDark) {
    final inputFill = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final inputBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PennyPal Emblem
          const PennyPalBrandLogo(
            iconSize: 58,
            titleFontSize: 24,
            subtitleFontSize: 12.5,
          ),

          const SizedBox(height: 26),

          Text(
            'Verify & Reset',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Enter the 4-digit code sent to ${_emailPhoneController.text.trim()}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: subtextColor,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 4-Digit OTP Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: inputFill,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: inputBorder,
                        width: 1.4,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 3) {
                      _otpFocusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),

          const SizedBox(height: 18),

          // Resend Timer
          Center(
            child: _resendCountdown > 0
                ? Text(
                    'Resend code in ${_resendCountdown}s',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _startCountdown();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('New recovery code sent!'),
                          backgroundColor: AppColors.primaryBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 22),

          // New Password Field
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPass,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'New Password',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: inputFill,
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: subtextColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPass = !_obscureNewPass;
                  });
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: inputBorder,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.expenseRed,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.expenseRed,
                  width: 1.8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPass,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Confirm New Password',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: inputFill,
              prefixIcon: Icon(
                Icons.lock_reset_rounded,
                size: 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: subtextColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPass = !_obscureConfirmPass;
                  });
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: inputBorder,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.expenseRed,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.expenseRed,
                  width: 1.8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Confirm & Reset Password Button
          SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.35 : 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Update Password',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Back to Login link
          Center(
            child: TextButton(
              onPressed: _navigateToLogin,
              child: Text(
                'Cancel & Return to Login',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}