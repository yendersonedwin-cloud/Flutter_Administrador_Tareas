import 'dart:convert';
import 'dart:developer';

import '../../core/api_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  final ApiService _apiService = ApiService();

  Future<List<TaskModel>> getTareas() async {
    try {
      final response = await _apiService.get('/tareas/');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar tareas: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getTareas: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<TaskModel> createTarea(Map<String, dynamic> tareaData) async {
    try {
      final response = await _apiService.post('/tareas/', tareaData);

      if (response.statusCode == 201) {
        return TaskModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear tarea: ${response.body}');
      }
    } catch (e) {
      log('Error createTarea: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<TaskModel> updateTarea(int id, Map<String, dynamic> tareaData) async {
    try {
      final response = await _apiService.patch('/tareas/$id/', tareaData);

      if (response.statusCode == 200) {
        return TaskModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar tarea: ${response.body}');
      }
    } catch (e) {
      log('Error updateTarea: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<void> deleteTarea(int id) async {
    try {
      final response = await _apiService.delete('/tareas/$id/');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al eliminar tarea: ${response.statusCode}');
      }
    } catch (e) {
      log('Error deleteTarea: $e');
      throw Exception('Error de conexion: $e');
    }
  }

  Future<TaskModel> toggleComplete(int id, bool completada) async {
    return updateTarea(id, {'completada': !completada});
  }
}
