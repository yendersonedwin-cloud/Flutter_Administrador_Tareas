import 'dart:convert';
import 'dart:developer';

import '../../core/api_service.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final ApiService _apiService = ApiService();

  Future<PerfilModel> getMiPerfil() async {
    try {
      final response = await _apiService.get('/perfil/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return PerfilModel.fromJson(data.first as Map<String, dynamic>);
        }

        return PerfilModel.fromJson(data as Map<String, dynamic>);
      }

      throw Exception('Error al cargar perfil: ${response.statusCode}');
    } catch (e) {
      log('Error en getMiPerfil: $e');
      throw Exception('Error de conexion al obtener perfil: $e');
    }
  }

  Future<PerfilModel> updatePerfil(Map<String, dynamic> perfilData) async {
    try {
      final response = await _apiService.put('/perfil/', perfilData);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return PerfilModel.fromJson(data);
      }

      throw Exception('Error al actualizar perfil: ${response.body}');
    } catch (e) {
      log('Error en updatePerfil: $e');
      throw Exception('Error de conexion al actualizar perfil: $e');
    }
  }
}
