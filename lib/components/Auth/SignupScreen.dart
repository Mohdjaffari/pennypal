// ignore: file_names
import 'dart:math';
import 'dart:ui' show PointMode;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pages_app/HomePage.dart';
import 'package:pages_app/components/Auth/LoginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isPassHidden = true;

  late final TapGestureRecognizer _privacyTap;
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _loginTap;

  /// How far the white sheet climbs over the coloured header.
  static const double _sheetOverlap = 66;

  @override
  void initState() {
    super.initState();
    _privacyTap = TapGestureRecognizer()..onTap = () {/* TODO: open privacy policy */};
    _termsTap = TapGestureRecognizer()..onTap = () {/* TODO: open terms of service */};
    _loginTap = TapGestureRecognizer()..onTap = () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));};
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passController.dispose();
    _privacyTap.dispose();
    _termsTap.dispose();
    _loginTap.dispose();
    super.dispose();
  }

  void createAccount() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully'),
        ),
      );
    }
  }

  void _goBack() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const Homepage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = topInset + 250;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _SignupColors.sheet,
        body: Stack(
          children: [
            // Coloured header (stays put while the form scrolls over it)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroHeight,
              child: _Hero(topInset: topInset),
            ),

            // Scrollable white sheet
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: heroHeight - _sheetOverlap),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildSheet(context),
                ),
              ],
            ),

            // Back button
            Positioned(
              top: topInset + 4,
              left: 8,
              child: IconButton(
                tooltip: 'Back',
                onPressed: _goBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Sheet
  // -------------------------------------------------------------------------

  Widget _buildSheet(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final bodyStyle = GoogleFonts.figtree(
      fontSize: 14,
      height: 1.55,
      color: _SignupColors.muted,
    );
    final linkStyle = GoogleFonts.figtree(
      fontSize: 14,
      height: 1.55,
      color: _SignupColors.ink,
      decoration: TextDecoration.underline,
    );

    return Container(
      decoration: const BoxDecoration(
        color: _SignupColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.fromLTRB(24, 28, 24, 26 + bottomInset),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Google
              OutlinedButton(
                onPressed: () {/* TODO: start Google sign-in */},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: _SignupColors.hairline),
                  foregroundColor: _SignupColors.ink,
                  textStyle: GoogleFonts.figtree(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.string(_googleLogo, width: 20, height: 20),
                    const SizedBox(width: 12),
                    const Text('Sign in with Google'),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'or',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.figtree(
                    fontSize: 15,
                    color: _SignupColors.muted,
                  ),
                ),
              ),

              // First + last name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PillField(
                      controller: firstNameController,
                      hint: 'First Name',
                      autofillHints: const [AutofillHints.givenName],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _PillField(
                      controller: lastNameController,
                      hint: 'Last Name',
                      autofillHints: const [AutofillHints.familyName],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Email
              _PillField(
                controller: emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Password + visibility toggle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PillField(
                      controller: passController,
                      hint: 'Password',
                      obscureText: isPassHidden,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => createAccount(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 characters required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Tooltip(
                    message: isPassHidden ? 'Show password' : 'Hide password',
                    child: Material(
                      color: _SignupColors.field,
                      shape: const StadiumBorder(),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: () {
                          setState(() {
                            isPassHidden = !isPassHidden;
                          });
                        },
                        child: SizedBox(
                          width: 56,
                          height: 54,
                          child: Icon(
                            isPassHidden
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 22,
                            color: _SignupColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Submit
              ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 58,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: createAccount,
                        style: FilledButton.styleFrom(
                          backgroundColor: _SignupColors.ink,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          textStyle: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Create account'),
                      ),
                    ),
                    const Positioned.fill(child: _GrainOverlay(opacity: .09)),
                  ],
                ),
              ),

              // Legal
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 22, 4, 0),
                child: Text.rich(
                  TextSpan(
                    style: bodyStyle,
                    children: [
                      const TextSpan(text: 'Signing up means you agree to the '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: linkStyle,
                        recognizer: _privacyTap,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: linkStyle,
                        recognizer: _termsTap,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Switch to log in
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.figtree(
                      fontSize: 16,
                      color: _SignupColors.ink,
                    ),
                    children: [
                      const TextSpan(text: 'Have an account? '),
                      TextSpan(
                        text: 'Log in here',
                        recognizer: _loginTap,
                        style: const TextStyle(
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
// Design tokens
// ---------------------------------------------------------------------------

abstract final class _SignupColors {
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

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: _SignupColors.orange)),
        const Positioned(
          left: -118,
          top: 58,
          child: _Blob(size: 200, color: _SignupColors.gold),
        ),
        const Positioned(
          right: -88,
          top: 116,
          child: _Blob(size: 190, color: _SignupColors.green),
        ),
        const Positioned.fill(child: _GrainOverlay()),
        Positioned(
          top: topInset + 62,
          left: 24,
          right: 24,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 212),
              child: Text(
                'Create an account',
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
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pill-shaped text field
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

  static OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: color == null
            ? BorderSide.none
            : BorderSide(color: color, width: 1.5),
      );

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
      cursorColor: _SignupColors.ink,
      style: GoogleFonts.figtree(fontSize: 16, color: _SignupColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.figtree(
          fontSize: 16,
          color: _SignupColors.placeholder,
        ),
        filled: true,
        fillColor: _SignupColors.field,
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(_SignupColors.ink),
        errorBorder: _border(_SignupColors.error),
        focusedErrorBorder: _border(_SignupColors.error),
        errorStyle: GoogleFonts.figtree(
          fontSize: 12.5,
          height: 1.3,
          color: _SignupColors.error,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Film grain (speckled texture on the header and the black button)
// ---------------------------------------------------------------------------

class _GrainOverlay extends StatelessWidget {
  const _GrainOverlay({this.opacity = .07});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _GrainPainter(opacity)),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7); // fixed seed: the grain never shimmers
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
  bool shouldRepaint(covariant _GrainPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}