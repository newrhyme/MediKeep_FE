import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  static const _tokenKey = 'jwt_token';

  /// 로그인: 성공 시 JWT 토큰을 로컬에 저장하고 토큰을 리턴
  static Future<String> login(
      {required String email, required String password}) async {
    final res = await ApiClient.postJson('/api/users/login', {
      'email': email,
      'password': password,
    });

    if (res.statusCode == 200) {
      // 백엔드 응답 형태에 맞춰 파싱 (예: {"token":"..."} or Authorization 헤더 등)
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final token = (map['token'] ?? map['accessToken'] ?? '').toString();
      if (token.isEmpty) {
        throw Exception('Token not found in response');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return token;
    } else {
      // 서버에서 에러 메시지 내려주면 같이 보여주기
      final msg =
          res.body.isNotEmpty ? res.body : 'Login failed (${res.statusCode})';
      throw Exception(msg);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
