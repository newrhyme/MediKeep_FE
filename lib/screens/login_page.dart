import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medikeep/screens/temp_humidity_test_page.dart';
import 'signup_page.dart';
import 'add_schedule_page.dart';
import 'dashboard_page.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color bg = Color(0xFFC6F2FF);
  static const Color navy = Color(0xFF2D4868);
  static const double radius = 12;

  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  bool get _canSubmit =>
      _emailCtrl.text.trim().isNotEmpty && _pwCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onChanged);
    _pwCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.carterOne(fontSize: 14, color: navy.withOpacity(.45)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: navy.withOpacity(.25), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: navy, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(40, 250, 40, 24),
          children: [
            // Title
            Text(
              'Log in',
              textAlign: TextAlign.center,
              style: GoogleFonts.carterOne(
                fontSize: 50,
                color: navy,
                fontWeight: FontWeight.w900, // 더 두껍게
              ),
            ),
            const SizedBox(height: 50),

            // Email label
            Text('Email',
                style: GoogleFonts.carterOne(
                    fontSize: 20, color: navy, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),

            // Email field
            TextField(
              controller: _emailCtrl,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.carterOne(fontSize: 18, color: navy),
              decoration: _fieldDeco('Please enter your Email'),
            ),
            const SizedBox(height: 18),

            // PW label
            Text('P/W',
                style: GoogleFonts.carterOne(
                    fontSize: 20, color: navy, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),

            // PW field
            TextField(
              controller: _pwCtrl,
              obscureText: _obscure,
              style: GoogleFonts.carterOne(fontSize: 18, color: navy),
              decoration: _fieldDeco('Please enter your P/W').copyWith(
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                      color: navy),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Login button
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
                child: const Text('Log in'),
              ),
            ),
            const SizedBox(height: 20),

            // If you don't have account? Sign up
            Center(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.carterOne(
                      fontSize: 14, color: navy.withOpacity(.7)),
                  children: [
                    const TextSpan(text: "If you don’t have account? "),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage()),
                          );
                        },
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.carterOne(
                            fontSize: 14,
                            color: navy,
                            decoration: TextDecoration.underline,
                            decorationColor: navy,
                          ),
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

  void _onSubmit() async {
    if (!_canSubmit || _loading) return;

    setState(() => _loading = true);
    try {
      final ok = await AuthService.I.login(_emailCtrl.text, _pwCtrl.text);
      if (!mounted) return;

      if (ok) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Login failed', style: GoogleFonts.carterOne())),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e', style: GoogleFonts.carterOne())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
