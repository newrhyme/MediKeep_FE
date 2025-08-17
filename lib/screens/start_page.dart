import 'package:flutter/material.dart';
import 'package:medikeep/screens/login_page.dart';
import 'package:medikeep/screens/signup_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6F2FF), // 배경색
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지
            Center(
              child: Image.asset(
                'assets/logo2.png', // pubspec.yaml 등록 필요
                width: 462,
                height: 462,
              ),
            ),
            // Log in 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4868), // 짙은 파란색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // TODO: 로그인 페이지 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 흰색 배경
                    foregroundColor: const Color(0xFF2D4868), // 글자색
                    side: const BorderSide(
                        color: Color(0xFF2D4868), width: 2), // 테두리
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // TODO: 회원가입 페이지 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
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
