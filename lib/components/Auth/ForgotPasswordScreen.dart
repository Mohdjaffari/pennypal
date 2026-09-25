import 'dart:math';
import 'dart:ui' show PointMode;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pages_app/components/Auth/LoginScreen.dart';

class AppColors {
  static const orange = Color(0xFFE9744F);
  static const gold = Color(0xFFD9BD73);
  static const green = Color(0xFF62C08F);

  static const sheet = Color(0xFFFFFFFF);
  static const field = Color(0xFFF4F4F4);
  static const ink = Color(0xFF0A0A0A);
  static const placeholder = Color(0xFF8D8D8D);
  static const muted = Color(0xFF666666);
  static const hairline = Color(0xFFD9D9D9);
  static const error = Color(0xFFC4392B);
}

void main() {
  runApp(const ForgotPasswordApp());
}

class ForgotPasswordApp extends StatelessWidget {
  const ForgotPasswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Forgot Password',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orange,
        ),
        textTheme: GoogleFonts.figtreeTextTheme(),
      ),
      home: const ForgotPasswordScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// FORGOT PASSWORD SCREEN
// ---------------------------------------------------------------------------

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  static const double _sheetOverlap = 66;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = topInset + 250;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.sheet,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sheet,
        body: Stack(
          children: [
            // ---------------------------------------------------------------
            // HERO
            // ---------------------------------------------------------------

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroHeight,
              child: _ForgotPasswordHero(
                topInset: topInset,
              ),
            ),

            // ---------------------------------------------------------------
            // CONTENT
            // ---------------------------------------------------------------

            CustomScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: heroHeight - _sheetOverlap,
                  ),
                ),

                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ForgotPasswordSheet(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HERO
// ---------------------------------------------------------------------------

class _ForgotPasswordHero extends StatelessWidget {
  const _ForgotPasswordHero({
    required this.topInset,
  });

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        const Positioned.fill(
          child: ColoredBox(
            color: AppColors.orange,
          ),
        ),

        // Decorative blobs
        const Positioned(
          left: -118,
          top: 58,
          child: _Blob(
            size: 200,
            color: AppColors.gold,
          ),
        ),

        const Positioned(
          right: -88,
          top: 116,
          child: _Blob(
            size: 190,
            color: AppColors.green,
          ),
        ),

        // Grain texture
        const Positioned.fill(
          child: GrainOverlay(),
        ),

        // Hero title
        Positioned(
          top: topInset + 52,
          left: 24,
          right: 24,
          child: Column(
            children: [
              Text(
                'Forgot password?',
                textAlign: TextAlign.center,
                style: GoogleFonts.figtree(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.12,
                  letterSpacing: -0.3,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Let’s get you back into your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.figtree(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: Colors.white.withOpacity(.88),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// BLOB
// ---------------------------------------------------------------------------

class _Blob extends StatelessWidget {
  const _Blob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FORGOT PASSWORD SHEET
// ---------------------------------------------------------------------------

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();

  @override
  State<_ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState
    extends State<_ForgotPasswordSheet> {

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  late final TapGestureRecognizer _loginTap;

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();

    _loginTap = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
      };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _loginTap.dispose();

    super.dispose();
  }

  // -------------------------------------------------------------------------
  // EMAIL VALIDATION
  // -------------------------------------------------------------------------

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email';
    }

    if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // -------------------------------------------------------------------------
  // SEND RESET LINK
  // -------------------------------------------------------------------------

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();

    debugPrint('Password reset requested for: $email');

    // -----------------------------------------------------------------------
    // TODO:
    // Connect Firebase Authentication or your backend API here.
    //
    // Example:
    //
    // await FirebaseAuth.instance.sendPasswordResetEmail(
    //   email: email,
    // );
    // -----------------------------------------------------------------------

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        28,
        24,
        26 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ---------------------------------------------------------------
            // ICON
            // ---------------------------------------------------------------

            Center(
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 29,
                  color: AppColors.ink,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ---------------------------------------------------------------
            // TITLE
            // ---------------------------------------------------------------

            Text(
              _emailSent
                  ? 'Check your inbox'
                  : 'Reset your password',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -.2,
              ),
            ),

            const SizedBox(height: 8),

            // ---------------------------------------------------------------
            // DESCRIPTION
            // ---------------------------------------------------------------

            Text(
              _emailSent
                  ? 'If an account exists for this email, '
                      'we’ve sent you a password reset link.'
                  : 'Enter the email address associated with your '
                      'account and we’ll send you a secure reset link.',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 14,
                height: 1.45,
                color: AppColors.muted,
              ),
            ),

            const SizedBox(height: 24),

            // ---------------------------------------------------------------
            // EMAIL FIELD
            // ---------------------------------------------------------------

            if (!_emailSent) ...[
              _PillField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.username,
                ],
                textInputAction: TextInputAction.done,
                validator: _validateEmail,
                onSubmitted: (_) => _sendResetLink(),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // RESET BUTTON
              // -------------------------------------------------------------

              ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 58,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            _isLoading ? null : _sendResetLink,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          disabledBackgroundColor:
                              AppColors.ink.withOpacity(.55),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 200,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  key: ValueKey('loader'),
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Send reset link',
                                  key: ValueKey('text'),
                                ),
                        ),
                      ),
                    ),

                    const Positioned.fill(
                      child: GrainOverlay(
                        opacity: .09,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ---------------------------------------------------------------
            // SUCCESS STATE
            // ---------------------------------------------------------------

            if (_emailSent) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.green.withOpacity(.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Check your email and follow the '
                        'instructions to create a new password.',
                        style: GoogleFonts.figtree(
                          fontSize: 13.5,
                          height: 1.4,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Resend
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : _sendResetLink,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                  side: const BorderSide(
                    color: AppColors.hairline,
                  ),
                  foregroundColor: AppColors.ink,
                  textStyle: GoogleFonts.figtree(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text(
                  'Send again',
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ---------------------------------------------------------------
            // BACK TO LOGIN
            // ---------------------------------------------------------------

            Text.rich(
              TextSpan(
                style: GoogleFonts.figtree(
                  fontSize: 15,
                  color: AppColors.ink,
                ),
                children: [
                  const TextSpan(
                    text: 'Remember your password? ',
                  ),

                  TextSpan(
                    text: 'Login',
                    recognizer: _loginTap,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REUSABLE PILL FIELD
// ---------------------------------------------------------------------------

class _PillField extends StatelessWidget {
  const _PillField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted, 
    this.obscureText= false
  });

  final TextEditingController controller;
  final String hint;

  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  static OutlineInputBorder _border([
    Color? color,
  ]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(100),
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(
              color: color,
              width: 1.5,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      cursorColor: AppColors.ink,
      style: GoogleFonts.figtree(
        fontSize: 16,
        color: AppColors.ink,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.figtree(
          fontSize: 16,
          color: AppColors.placeholder,
        ),
        filled: true,
        fillColor: AppColors.field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 17,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(
          AppColors.ink,
        ),
        errorBorder: _border(
          AppColors.error,
        ),
        focusedErrorBorder: _border(
          AppColors.error,
        ),
        errorStyle: GoogleFonts.figtree(
          fontSize: 12.5,
          height: 1.3,
          color: AppColors.error,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GRAIN OVERLAY
// ---------------------------------------------------------------------------

class GrainOverlay extends StatelessWidget {
  const GrainOverlay({
    super.key,
    this.opacity = .07,
  });

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GrainPainter(opacity),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.opacity);

  final double opacity;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final random = Random(7);

    final count =
        (size.width * size.height / 10).round();

    final light = <Offset>[];
    final dark = <Offset>[];

    for (var i = 0; i < count; i++) {
      final point = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );

      (random.nextBool() ? light : dark).add(point);
    }

    final alpha = (opacity * 255).round();

    final paint = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.square;

    canvas.drawPoints(
      PointMode.points,
      light,
      paint..color = Colors.white.withAlpha(alpha),
    );

    canvas.drawPoints(
      PointMode.points,
      dark,
      paint..color = Colors.black.withAlpha(alpha),
    );
  }

  @override
  bool shouldRepaint(
    covariant _GrainPainter oldDelegate,
  ) {
    return oldDelegate.opacity != opacity;
  }
}