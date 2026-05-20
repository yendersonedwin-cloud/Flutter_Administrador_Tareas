// lib/data/repositories/auth_repository.dart

import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import '../../core/api_config.dart';

class LoginResponse {
  final String token;
  final int userId;
  final String? username;
  
  LoginResponse({
    required this.token,
    required this.userId,
    this.username,
  });
}

class RegisterResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? errors;
  
  RegisterResponse({
    required this.success,
    required this.message,
    this.errors,
  });
}

class AuthRepository {
  final ApiService _apiService = ApiService();

 Future<LoginResponse?> login(String username, String password) async {
  try {
    log('🔐 Intentando login con: $username');
    
    final response = await _apiService.post(ApiConfig.loginEndpoint, {
      'username': username,
      'password': password,
    });
    
    log('📡 Status code: ${response.statusCode}');
    log('📦 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('✅ Data decodificada: $data');
      // En auth_repository.dart, dentro de login()
log('📦 Respuesta COMPLETA del backend: ${response.body}');
      
    // 🔧 LECTURA DE TOKEN MEJORADA
String token = '';

// Intenta obtener el token desde diferentes formatos
final rawToken = data['token'];
if (rawToken is String) {
  token = rawToken;
} else if (rawToken is Map) {
  // Formato: { "token": { "access": "..." } }
  token = (rawToken['access'] ?? rawToken['token'] ?? '').toString();
}

// Si no se encontró token, busca en otros campos comunes
if (token.isEmpty) {
  token = (data['access'] ?? data['access_token'] ?? data['key'] ?? '').toString();
}

// 🔧 LECTURA DE USERID MEJORADA
int userId = 0;
final rawUserId = data['user_id'] ?? data['id'] ?? data['usuario_id'] ?? 0;
if (rawUserId is int) {
  userId = rawUserId;
} else {
  userId = int.tryParse(rawUserId.toString()) ?? 0;
}
      
      if (token.isNotEmpty) {
        await _apiService.saveToken(token);
        await _saveSessionData(token, userId, username);
        
        return LoginResponse(
          token: token,
          userId: userId,
          username: username,
        );
      } else {
        log('❌ Token vacío en la respuesta');
      }
    } else {
      log('❌ Status code no es 200: ${response.statusCode}');
    }
    return null;
  } catch (e) {
    log('❌ Error login: $e');
    return null;
  }
}

  // ✅ MÉTODO DE REGISTRO
  Future<RegisterResponse> register({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await _apiService.post(ApiConfig.registerEndpoint, {
        'username': username,
        'email': email,
        'password': password,
        'password2': password2,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return RegisterResponse(
          success: true,
          message: data['message'] ?? 'Usuario creado exitosamente',
        );
      } else {
        final data = json.decode(response.body);
        // Manejar errores de validación de Django
        String errorMessage = 'Error al registrar usuario';
        Map<String, dynamic>? errorDetails;
        
        if (data is Map) {
          if (data.containsKey('username')) {
            errorMessage = data['username'].join(', ');
            errorDetails = {'username': data['username']};
          } else if (data.containsKey('email')) {
            errorMessage = data['email'].join(', ');
            errorDetails = {'email': data['email']};
          } else if (data.containsKey('password')) {
            errorMessage = data['password'].join(', ');
            errorDetails = {'password': data['password']};
          } else if (data.containsKey('non_field_errors')) {
            errorMessage = data['non_field_errors'].join(', ');
          } else if (data.containsKey('error')) {
            errorMessage = data['error'];
          }
        }
        
        return RegisterResponse(
          success: false,
          message: errorMessage,
          errors: errorDetails,
        );
      }
    } catch (e) {
      log('Error register: $e');
      return RegisterResponse(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  Future<void> _saveSessionData(String token, int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('user_id', userId);
    await prefs.setString('username', username);
  }

  Future<Map<String, dynamic>?> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');
    
    if (token != null && userId != null) {
      return {
        'token': token,
        'userId': userId,
        'username': prefs.getString('username') ?? '',
      };
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('username');
  }
}

