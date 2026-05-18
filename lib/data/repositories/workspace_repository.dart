import 'dart:convert';
import 'dart:developer';

import '../../core/api_service.dart';
import '../models/workspace_model.dart';
import '../models/task_model.dart';

class WorkspaceRepository {
  final ApiService _apiService = ApiService();

  // 1. Obtener la lista de Workspaces del usuario logueado
  Future<List<WorkspaceModel>> getWorkspaces() async {
    try {
      final response = await _apiService.get('/workspaces/');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => WorkspaceModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar workspaces: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getWorkspaces: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // 2. Crear un nuevo Workspace (Rol: Admin automático en Django)
  Future<WorkspaceModel> createWorkspace(Map<String, dynamic> workspaceData) async {
    try {
      final response = await _apiService.post('/workspaces/', workspaceData);

      if (response.statusCode == 201) {
        return WorkspaceModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear workspace: ${response.body}');
      }
    } catch (e) {
      log('Error createWorkspace: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // 3. Unirse a un Workspace existente usando el Código de invitación (Rol: Miembro)
  Future<bool> joinWorkspace(String codigo) async {
    try {
      // Enviamos el código al endpoint de join configurado en Django
      final response = await _apiService.post('/workspaces/join/', {'codigo': codigo});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        log('No se pudo unir al workspace: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error joinWorkspace: $e');
      return false;
    }
  }

  // 4. Cargar todas las tareas compartidas del Workspace actual
  Future<List<TaskModel>> getWorkspaceTasks(int workspaceId) async {
    try {
      final response = await _apiService.get('/workspaces/$workspaceId/tasks/');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar tareas del equipo: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getWorkspaceTasks: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // 5. Eliminar el Workspace completo (Permiso exclusivo del Admin en Django)
  Future<void> deleteWorkspace(int workspaceId) async {
    try {
      final response = await _apiService.delete('/workspaces/$workspaceId/');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al eliminar workspace: ${response.statusCode}');
      }
    } catch (e) {
      log('Error deleteWorkspace: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}