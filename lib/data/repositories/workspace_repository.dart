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

  // 2. Crear un nuevo Workspace
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

  // 3. Unirse a un Workspace existente usando el Código de invitación
  Future<bool> joinWorkspace(String codigo) async {
    try {
      final response = await _apiService.post('/workspaces/join_by_code/', {
        'codigo': codigo,
      });

      return response.statusCode == 200 || response.statusCode == 201;
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

  // 5. Eliminar el Workspace completo
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

  // 6. Obtener miembros del workspace desde las tareas (compatible con tu backend)
  Future<List<Map<String, dynamic>>> getWorkspaceMembers(int workspaceId) async {
    try {
      // Obtenemos las tareas del workspace
      final response = await _apiService.get('/workspaces/$workspaceId/tasks/');
      
      if (response.statusCode == 200) {
        final List tasks = json.decode(response.body);
        final Map<int, Map<String, dynamic>> uniqueMembers = {};
        
        for (final task in tasks) {
          // Usuario que creó la tarea (viene en 'usuario_info' según TareaSerializer)
          if (task['usuario_info'] != null) {
            final user = task['usuario_info'] as Map<String, dynamic>;
            uniqueMembers[user['id']] = {
              'id': user['id'],
              'username': user['username'] ?? 'Usuario',
              'email': user['email'] ?? '',
              'first_name': user['first_name'] ?? '',
              'last_name': user['last_name'] ?? '',
              'rol': _determinarRol(workspaceId, user['id']),
            };
          }
          
          // Usuario asignado a la tarea (viene en 'asignado_info')
          if (task['asignado_info'] != null) {
            final user = task['asignado_info'] as Map<String, dynamic>;
            if (!uniqueMembers.containsKey(user['id'])) {
              uniqueMembers[user['id']] = {
                'id': user['id'],
                'username': user['username'] ?? 'Usuario',
                'email': user['email'] ?? '',
                'first_name': user['first_name'] ?? '',
                'last_name': user['last_name'] ?? '',
                'rol': _determinarRol(workspaceId, user['id']),
              };
            }
          }
        }
        
        // Si no hay tareas, intentamos obtener miembros desde el endpoint de métricas
        if (uniqueMembers.isEmpty) {
          return await _getMembersFromAdminPanel(workspaceId);
        }
        
        return uniqueMembers.values.toList();
      }
      
      return [];
    } catch (e) {
      log('Error getWorkspaceMembers: $e');
      return [];
    }
  }
  
  // Método alternativo: obtener miembros desde el panel de admin
  Future<List<Map<String, dynamic>>> _getMembersFromAdminPanel(int workspaceId) async {
    try {
      // Nota: Este endpoint probablemente no existe en tu API REST,
      // pero lo dejamos como fallback. En tu caso, devolverá error 404.
      final response = await _apiService.get('/workspaces/$workspaceId/panel_admin/');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['miembros_data'] != null) {
          return (data['miembros_data'] as List).map((m) {
            final user = m['usuario'];
            return {
              'id': user['id'],
              'username': user['username'],
              'email': user['email'],
              'first_name': user['first_name'] ?? '',
              'last_name': user['last_name'] ?? '',
              'rol': m['rol'] ?? 'Miembro',
              'total_tareas': m['total_tareas'],
              'tareas_hechas': m['tareas_hechas'],
              'productividad': m['productividad'],
            };
          }).toList();
        }
      }
      return [];
    } catch (e) {
      log('Error en _getMembersFromAdminPanel: $e');
      return [];
    }
  }
  
  String _determinarRol(int workspaceId, int userId) {
    // Por ahora, solo sabemos que el usuario actual es admin si coincide con el admin del workspace
    // Para esto necesitaríamos tener el workspace completo. 
    // Por simplicidad, retornamos 'Miembro' como default.
    // En la práctica, podrías obtener esta información del workspace cuando lo cargas.
    return 'Miembro';
  }
}