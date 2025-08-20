// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://192.168.1.3:8080'; // 네 맥 IP
  static String? _token; // JWT 저장

  /// 로그인/부트스트랩/로그아웃 모두 커버 (null 허용)
  static void setToken(String? token) {
    _token = (token != null && token.isNotEmpty) ? token : null;
  }

  static Future<http.Response> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
        ...?headers,
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> getJson(
    String path, {
    Map<String, String>? headers,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
        ...?headers,
      },
    );
  }
}
