import 'dart:convert';
import 'dart:developer';
import '../../core/api_service.dart';
import '../models/workspace_model.dart';

class WorkspaceRepository {
  final ApiService _apiService = ApiService();

  // Obtener la lista de todos los workspaces del usuario
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

  // Crear un nuevo workspace
  Future<void> createWorkspace(Map<String, dynamic> workspaceData) async {
  try {
    final response = await _apiService.post('/workspaces/', workspaceData);

    // Verificamos si Django devolvió 201 Created o 200 OK
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear workspace: ${response.body}');
    }
  } catch (e) {
    log('Error createWorkspace: $e');
    throw Exception('Error de conexión: $e');
  }
}
}