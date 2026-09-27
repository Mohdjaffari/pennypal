// ignore_for_file: file_names
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/theme_service.dart';
import '../../HomePage.dart';
import 'ForgotPasswordScreen.dart';
import 'SignupScreen.dart';
import 'penny_pal_brand_logo.dart';

const String _googleSvg = '''
<svg viewBox="0 0 24 24" width="24" height="24" xmlns="http://www.w3.org/2000/svg">
  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" fill="#FBBC05"/>
  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z" fill="#EA4335"/>
</svg>
''';

/// Professional, highly polished Login Screen for PennyPal.
/// Formatted cleanly with deep Light & Dark mode support:
/// - PennyPal Brand Emblem & Two-Tone Wordmark ("Penny" Blue + "Pal" Pink)
/// - Interactive Theme Toggle in AppBar
/// - "Welcome Back!" & "Login to your account"
/// - Email/Phone and Password inputs with live validation badges
/// - "Remember me" checkbox + "Forgot Password?" interactive link
/// - Royal Blue "Login" action button with haptic feedback
/// - "or continue with" divider + Branded Google social sign-in (Apple removed)
/// - "Don't have an account? Register" footer
class LoginScreen extends StatefulWidget {
  final String? redirectReason;

  const LoginScreen({
    super.key,
    this.redirectReason,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _identifierFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _isIdentifierValid = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final TapGestureRecognizer _registerTap;

  @override
  void initState() {
    super.initState();

    ThemeService.instance.addListener(_handleThemeChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

    _identifierController.addListener(_checkIdentifierValidity);

    _registerTap = TapGestureRecognizer()..onTap = _navigateToSignup;

    _animController.forward();
  }

  void _handleThemeChanged() {
    if (mounted) setState(() {});
  }

  void _checkIdentifierValidity() {
    final text = _identifierController.text.trim();
    final isValidEmail =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    final isValidPhone =
        RegExp(r'^[+0-9\s-]{9,15}$').hasMatch(text);

    final valid = isValidEmail || isValidPhone;
    if (valid != _isIdentifierValid) {
      setState(() => _isIdentifierValid = valid);
    }
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_handleThemeChanged);
    _animController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    _registerTap.dispose();
    super.dispose();
  }

  void _navigateToSignup() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToForgotPassword() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ForgotPasswordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  Future<void> _handleLogin() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    final input = _identifierController.text.trim();
    final derivedName = input.contains('@')
        ? input.split('@').first
        : (input.length > 4 ? 'User ${input.substring(input.length - 4)}' : 'Mohd Jaffari');

    await AuthService.instance.login(
      name: derivedName.isNotEmpty
          ? '${derivedName[0].toUpperCase()}${derivedName.substring(1)}'
          : 'Mohd Jaffari',
    );

    if (_rememberMe) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pennypal_saved_identifier', input);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Welcome back to PennyPal!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1400),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      }
    });
  }

  void _handleSocialLogin(String provider) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Authenticating with $provider...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1000),
      ),
    );

    Future.delayed(const Duration(milliseconds: 650), () async {
      if (mounted) {
        await AuthService.instance.login(name: '$provider User');

        if (!mounted) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Homepage()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.instance.isDark(context);

    // Dynamic Theme Tokens
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFD);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            leading: Navigator.of(context).canPop()
                ? Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textPrimary,
                          size: 16,
                        ),
                      ),
                      tooltip: 'Back',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop(false);
                      },
                    ),
                  )
                : null,
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. PennyPal Brand Emblem & Two-Tone Tagline
                            const PennyPalBrandLogo(
                              iconSize: 58,
                              titleFontSize: 24,
                              subtitleFontSize: 12.5,
                            ),

                            // Guest redirect banner if redirected
                            if (widget.redirectReason != null) ...[
                              Container(
                                margin: const EdgeInsets.only(top: 18),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.primaryBlue.withValues(alpha: 0.16)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.primaryBlue.withValues(alpha: 0.35)
                                        : const Color(0xFFBFDBFE),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.primaryBlue.withValues(alpha: 0.25)
                                            : const Color(0xFFDBEAFE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lock_person_rounded,
                                        color: AppColors.primaryBlue,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.redirectReason!,
                                        style: GoogleFonts.inter(
                                          color: isDark
                                              ? const Color(0xFF93C5FD)
                                              : const Color(0xFF1E40AF),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 26),

                            // 2. Titles
                            Text(
                              'Welcome Back!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Login to your account',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: textSecondary,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // 3. Email or Phone Input
                            _buildInputField(
                              controller: _identifierController,
                              focusNode: _identifierFocus,
                              hint: 'Email or Phone',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              isDark: isDark,
                              suffixWidget: _isIdentifierValid
                                  ? const Padding(
                                      padding: EdgeInsets.only(right: 14.0),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.successGreen,
                                        size: 18,
                                      ),
                                    )
                                  : null,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your email or phone';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // 4. Password Input
                            _buildInputField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              hint: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              isDark: isDark,
                              suffixWidget: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (val.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // 5. Remember Me & Forgot Password Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (val) {
                                          HapticFeedback.selectionClick();
                                          setState(() => _rememberMe = val ?? false);
                                        },
                                        activeColor: AppColors.primaryBlue,
                                        checkColor: Colors.white,
                                        side: BorderSide(
                                          color: isDark
                                              ? const Color(0xFF475569)
                                              : const Color(0xFFCBD5E1),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() => _rememberMe = !_rememberMe);
                                      },
                                      child: Text(
                                        'Remember me',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? const Color(0xFFCBD5E1)
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _navigateToForgotPassword,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: AppColors.primaryBlue,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // 6. Login Action Button (Rose Gradient)
                            SizedBox(
                              height: 52,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF43F5E),
                                      Color(0xFFE11D48),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF43F5E)
                                          .withValues(alpha: isDark ? 0.35 : 0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
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
                                          'Login',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 7. Divider "or continue with"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: borderColor,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text(
                                    'or continue with',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: borderColor,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // 8. Google Social Sign-In Button (Apple Removed!)
                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () => _handleSocialLogin('Google'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: surfaceColor,
                                  foregroundColor: textPrimary,
                                  side: BorderSide(color: borderColor, width: 1.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.string(
                                      _googleSvg,
                                      width: 21,
                                      height: 21,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // 9. Footer: Don't have an account? Register
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Register',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      recognizer: _registerTap,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffixWidget,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final inputFillColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final inputBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        filled: true,
        fillColor: inputFillColor,
        prefixIcon: Icon(
          icon,
          size: 20,
          color: textSecondary,
        ),
        suffixIcon: suffixWidget,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: inputBorderColor,
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
    );
  }
}