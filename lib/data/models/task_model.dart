class TaskModel {
  final int? id;
  final String titulo;
  final String descripcion;
  final String prioridad;
  final String estado;
  final DateTime? fechaVencimiento;
  final bool completada;
  final bool enProgreso;
  final int? categoriaId;
  final int? workspaceId;
  final int? asignadoA;
  final DateTime creadoEn;
  final DateTime updatedAt;

  // Información extra del serializer (para mostrar nombres)
  final Map<String, dynamic>? categoriaInfo;
  final Map<String, dynamic>? workspaceInfo;
  final Map<String, dynamic>? usuarioInfo;
  final Map<String, dynamic>? asignadoInfo;

  TaskModel({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    this.fechaVencimiento,
    required this.completada,
    required this.enProgreso,
    this.categoriaId,
    this.workspaceId,
    this.asignadoA,
    required this.creadoEn,
    required this.updatedAt,
    this.categoriaInfo,
    this.workspaceInfo,
    this.usuarioInfo,
    this.asignadoInfo,
  });

  // Convertir JSON a TaskModel
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      prioridad: _mapPrioridad(json['prioridad']),
      estado: json['estado'] ?? 'TODO',
      fechaVencimiento: json['fecha_vencimiento'] != null
          ? DateTime.parse(json['fecha_vencimiento'])
          : null,
      completada: json['completada'] ?? false,
      enProgreso: json['en_progreso'] ?? false,
      categoriaId: json['categoria'],
      workspaceId: json['workspace'],
      asignadoA: json['asignado_a'],
      creadoEn: DateTime.parse(json['creado_en']),
      updatedAt: DateTime.parse(json['updated_at']),
      categoriaInfo: json['categoria_info'],
      workspaceInfo: json['workspace_info'],
      usuarioInfo: json['usuario_info'],
      asignadoInfo: json['asignado_info'],
    );
  }

  // Convertir TaskModel a JSON (para enviar a la API)
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': _mapPrioridadInversa(prioridad),
      'estado': estado,
      if (fechaVencimiento != null)
        'fecha_vencimiento': fechaVencimiento!.toIso8601String().split('T')[0],
      'completada': completada,
      'en_progreso': enProgreso,
      if (categoriaId != null) 'categoria': categoriaId,
      if (workspaceId != null) 'workspace': workspaceId,
      if (asignadoA != null) 'asignado_a': asignadoA,
    };
  }

  // Mapear prioridad de Django ('A', 'M', 'B') a String
  static String _mapPrioridad(String prioridad) {
    switch (prioridad) {
      case 'A':
        return 'Alta';
      case 'M':
        return 'Media';
      case 'B':
        return 'Baja';
      default:
        return 'Media';
    }
  }

  // Mapear prioridad de String a código Django
  static String _mapPrioridadInversa(String prioridad) {
    switch (prioridad) {
      case 'Alta':
        return 'A';
      case 'Media':
        return 'M';
      case 'Baja':
        return 'B';
      default:
        return 'M';
    }
  }

  // Copiar con cambios
  TaskModel copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? prioridad,
    String? estado,
    DateTime? fechaVencimiento,
    bool? completada,
    bool? enProgreso,
    int? categoriaId,
    int? workspaceId,
    int? asignadoA,
  }) {
    return TaskModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      completada: completada ?? this.completada,
      enProgreso: enProgreso ?? this.enProgreso,
      categoriaId: categoriaId ?? this.categoriaId,
      workspaceId: workspaceId ?? this.workspaceId,
      asignadoA: asignadoA ?? this.asignadoA,
      creadoEn: creadoEn,
      updatedAt: updatedAt,
      categoriaInfo: categoriaInfo,
      workspaceInfo: workspaceInfo,
      usuarioInfo: usuarioInfo,
      asignadoInfo: asignadoInfo,
    );
  }

  // Obtener nombre de categoría (si está en categoriaInfo)
  String get nombreCategoria {
    return categoriaInfo?['nombre'] ?? 'Sin categoría';
  }

  // Obtener color de categoría
  String get colorCategoria {
    return categoriaInfo?['color'] ?? '#10b981';
  }
}
