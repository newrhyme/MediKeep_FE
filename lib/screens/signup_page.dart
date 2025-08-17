import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Theme
  static const Color bg = Color(0xFFC6F2FF);
  static const Color navy = Color(0xFF2D4868);
  static const double radius = 12;

  // Controllers
  final _nicknameCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _obscure = true;
  String? _emailError; // null이면 정상

  // 이메일 간단 검증
  bool _isValidEmail(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    // 심플 검증 (피그마 수준): @ 와 . 포함
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s);
  }

  bool get _canSubmit =>
      _nicknameCtrl.text.trim().isNotEmpty &&
      _pwCtrl.text.trim().isNotEmpty &&
      _isValidEmail(_emailCtrl.text);

  @override
  void initState() {
    super.initState();
    _nicknameCtrl.addListener(_onChanged);
    _pwCtrl.addListener(_onChanged);
    _emailCtrl.addListener(() {
      setState(() {
        _emailError = _emailCtrl.text.isEmpty
            ? null
            : (_isValidEmail(_emailCtrl.text) ? null : 'Invalid email address');
      });
    });
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _pwCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDeco(String hint, {String? error}) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: navy.withOpacity(.25), width: 1),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: navy, width: 1.6),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: Colors.red, width: 1.6),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.carterOne(fontSize: 14, color: navy.withOpacity(.45)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: baseBorder,
      focusedBorder: error == null ? focusedBorder : errorBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      errorText: error,
      errorStyle:
          GoogleFonts.carterOne(fontSize: 12, color: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(40, 200, 40, 24),
          children: [
            // Title
            Text(
              'Sign up',
              textAlign: TextAlign.center,
              style: GoogleFonts.carterOne(
                fontSize: 50,
                color: navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 28),

            // nickname
            Text('nickname',
                style: GoogleFonts.carterOne(
                    fontSize: 20, color: navy, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            TextField(
              controller: _nicknameCtrl,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.carterOne(fontSize: 18, color: navy),
              decoration: _fieldDeco('Please enter your nickname'),
            ),
            const SizedBox(height: 16),

            // password
            Text('password',
                style: GoogleFonts.carterOne(
                    fontSize: 20, color: navy, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            TextField(
              controller: _pwCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.carterOne(fontSize: 18, color: navy),
              decoration: _fieldDeco('Please enter your password').copyWith(
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: navy,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // email
            Text('email',
                style: GoogleFonts.carterOne(
                    fontSize: 20, color: navy, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.carterOne(fontSize: 18, color: navy),
              decoration:
                  _fieldDeco('Please enter your e-mail', error: _emailError),
            ),
            const SizedBox(height: 28),

            // Sign up button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit ? _onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  elevation: 1.5,
                  textStyle: GoogleFonts.carterOne(
                      fontSize: 25, fontWeight: FontWeight.w900),
                ),
                child: const Text('Sign up'),
              ),
            ),
            const SizedBox(height: 16),

            // bottom link
            Center(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.carterOne(
                      fontSize: 16, color: navy.withOpacity(.6)),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(), // 로그인으로
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text('Log in',
                              style: GoogleFonts.carterOne(
                                fontSize: 16,
                                color: navy,
                                decoration: TextDecoration.underline,
                                decorationColor: navy,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    // TODO: 실제 회원가입 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sign up: ${_nicknameCtrl.text} / ${_emailCtrl.text}',
          style: GoogleFonts.carterOne(),
        ),
      ),
    );
  }
}
