import 'dart:convert';
import 'dart:developer';

import '../../core/api_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getCategorias() async {
    try {
      final response = await _apiService.get('/categorias/');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar categorias: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getCategorias: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<CategoryModel> createCategoria(
    Map<String, dynamic> categoriaData,
  ) async {
    try {
      final response = await _apiService.post('/categorias/', categoriaData);

      if (response.statusCode == 201) {
        return CategoryModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear categoria: ${response.body}');
      }
    } catch (e) {
      log('Error createCategoria: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<CategoryModel> updateCategoria(
    int id,
    Map<String, dynamic> categoriaData,
  ) async {
    try {
      final response = await _apiService.put('/categorias/$id/', categoriaData);

      if (response.statusCode == 200) {
        return CategoryModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar categoria: ${response.body}');
      }
    } catch (e) {
      log('Error updateCategoria: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<void> deleteCategoria(int id) async {
    try {
      final response = await _apiService.delete('/categorias/$id/');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al eliminar categoria: ${response.statusCode}');
      }
    } catch (e) {
      log('Error deleteCategoria: $e');
      throw Exception('Error de conexion: $e');
    }
  }
}
