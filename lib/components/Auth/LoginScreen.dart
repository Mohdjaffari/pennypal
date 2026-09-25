import 'dart:math';
import 'dart:ui' show PointMode;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pages_app/components/Auth/ForgotPasswordScreen.dart';
import 'package:pages_app/components/Auth/SignupScreen.dart';

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

const String _googleLogo = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>
''';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orange,
        ),
        textTheme: GoogleFonts.figtreeTextTheme(),
      ),
      home: const LoginScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGIN SCREEN
// ---------------------------------------------------------------------------

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const double _sheetOverlap = 66;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = topInset + 250;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sheet,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroHeight,
              child: _LoginHero(topInset: topInset),
            ),

            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: heroHeight - _sheetOverlap,
                  ),
                ),

                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoginSheet(),
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

class _LoginHero extends StatelessWidget {
  const _LoginHero({
    required this.topInset,
  });

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(
            color: AppColors.orange,
          ),
        ),

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

        const Positioned.fill(
          child: GrainOverlay(),
        ),

        Positioned(
          top: topInset + 62,
          left: 24,
          right: 24,
          child: Center(
            child: Text(
              'Welcome back',
              textAlign: TextAlign.center,
              style: GoogleFonts.figtree(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.12,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
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
// LOGIN FORM
// ---------------------------------------------------------------------------

class _LoginSheet extends StatefulWidget {
  const _LoginSheet();

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late final TapGestureRecognizer _forgotPasswordTap;
  late final TapGestureRecognizer _signupTap;

  @override
  void initState() {
    super.initState();

    _forgotPasswordTap = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ForgotPasswordScreen()));
      };

    _signupTap = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignupScreen()));
      };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _forgotPasswordTap.dispose();
    _signupTap.dispose();

    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  void _login() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint('Email: $email');
    debugPrint('Password: $password');

    // TODO:
    // Connect your login API / Firebase authentication here.
  }

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
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -------------------------------------------------------------
              // GOOGLE LOGIN
              // -------------------------------------------------------------

              OutlinedButton(
                onPressed: () {
                  // TODO: Google authentication
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: const StadiumBorder(),
                  side: const BorderSide(
                    color: AppColors.hairline,
                  ),
                  foregroundColor: AppColors.ink,
                  textStyle: GoogleFonts.figtree(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.string(
                      _googleLogo,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Continue with Google'),
                  ],
                ),
              ),

              // -------------------------------------------------------------
              // DIVIDER
              // -------------------------------------------------------------

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppColors.hairline,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        'or',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                    ),

                    const Expanded(
                      child: Divider(
                        color: AppColors.hairline,
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------------------------------------------
              // EMAIL
              // -------------------------------------------------------------

              _PillField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),

              const SizedBox(height: 8),

              // -------------------------------------------------------------
              // PASSWORD
              // -------------------------------------------------------------

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PillField(
                      controller: _passwordController,
                      hint: 'Password',
                      obscureText: _obscurePassword,
                      autofillHints: const [
                        AutofillHints.password,
                      ],
                      textInputAction: TextInputAction.done,
                      validator: _validatePassword,
                      onSubmitted: (_) => _login(),
                    ),
                  ),

                  const SizedBox(width: 5),

                  Material(
                    color: AppColors.field,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: SizedBox(
                        width: 56,
                        height: 54,
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 22,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // -------------------------------------------------------------
              // REMEMBER + FORGOT
              // -------------------------------------------------------------

              Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 4,
                  right: 4,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side: const BorderSide(
                          color: AppColors.hairline,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      'Remember me',
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        color: AppColors.muted,
                      ),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (Context)=> ForgotPasswordScreen()));
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // LOGIN BUTTON
              // -------------------------------------------------------------

              ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 58,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _login,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Log in'),
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

              // -------------------------------------------------------------
              // SIGN UP
              // -------------------------------------------------------------

              Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                ),
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                    children: [
                      const TextSpan(
                        text: "Don't have an account? ",
                      ),

                      TextSpan(
                        text: 'Create one',
                        recognizer: _signupTap,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
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

    final count = (size.width * size.height / 10).round();

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