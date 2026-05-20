// lib/core/api_config.dart

class ApiConfig {
  // ✅ NUEVA IP (cámbiala aquí)
  static const String baseUrl = 'http://192.168.101.77:8080/api/v1';
  
  // Endpoints
  static const String loginEndpoint = '/login/';
  static const String registerEndpoint = '/register/';
  static const String tareasEndpoint = '/tareas/';
  static const String categoriasEndpoint = '/categorias/';
  static const String workspacesEndpoint = '/workspaces/';
  static const String perfilEndpoint = '/perfil/';
  static const String usuariosEndpoint = '/usuarios/';

  // URLs completas
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get tareasUrl => '$baseUrl$tareasEndpoint';
  static String get categoriasUrl => '$baseUrl$categoriasEndpoint';
  static String get workspacesUrl => '$baseUrl$workspacesEndpoint';
  static String get perfilUrl => '$baseUrl$perfilEndpoint';
  static String get usuariosUrl => '$baseUrl$usuariosEndpoint';

  static String tareaDetailUrl(int id) => '$baseUrl$tareasEndpoint$id/';
  static String categoriaDetailUrl(int id) => '$baseUrl$categoriasEndpoint$id/';
  static String workspaceDetailUrl(int id) => '$baseUrl$workspacesEndpoint$id/';
  static String workspaceJoinUrl(int id) => '$baseUrl$workspacesEndpoint$id/join/';
  static String workspaceTasksUrl(int id) => '$baseUrl$workspacesEndpoint$id/tasks/';
  static String perfilMeUrl() => '$baseUrl$perfilEndpoint/me/';
}