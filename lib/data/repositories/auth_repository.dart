import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      log('Login response: ${response.statusCode}');
      log('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];

        if (token != null) {
          await _apiService.saveToken(token);
          return token;
        }
      }
      return null;
    } catch (e) {
      log('Error en login: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _apiService.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
