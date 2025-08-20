// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService I = AuthService._();
  final _secure = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    final res = await ApiClient.postJson(
      "/api/users/login",
      {"email": email.trim(), "password": password.trim()},
    );

    // 임시 디버그
    // ignore: avoid_print
    print("LOGIN status=${res.statusCode} body=${res.body}");

    if (res.statusCode == 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      String token = '';

      if (map['token'] != null) {
        token = map['token'].toString();
      } else if (map['accessToken'] != null) {
        token = map['accessToken'].toString();
      } else if (map['data'] is Map && (map['data']['token'] != null)) {
        token = map['data']['token'].toString();
      } else if (map['data'] is String) {
        // ★ 여기 추가!
        token = map['data'] as String;
      }

      if (token.toLowerCase().startsWith('bearer ')) {
        token = token.substring(7).trim();
      }
      if (token.isEmpty) return false;

      await _secure.write(key: 'jwt', value: token);
      ApiClient.setToken(token);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _secure.delete(key: 'jwt');
    ApiClient.setToken(null);
  }

  Future<void> bootstrap() async {
    final t = await _secure.read(key: 'jwt');
    ApiClient.setToken(t);
  }
}
