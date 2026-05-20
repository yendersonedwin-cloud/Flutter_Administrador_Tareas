class TaskModel {
  final int? id;
  final String titulo;
  final String descripcion;
  final String prioridad; // 'A' = Alta, 'M' = Media, 'B' = Baja
  final String estado; // 'TODO', 'PROG', 'DONE'
  final bool completada;
  final bool enProgreso;
  final int? categoriaId;
  final int? workspaceId;
  final int? asignadoA;
  final DateTime? fechaVencimiento;
  
  // Información adicional del serializer de Django
  final Map<String, dynamic>? usuarioInfo;    // Información del creador
  final Map<String, dynamic>? asignadoInfo;   // Información del asignado
  final Map<String, dynamic>? categoriaInfo;  // Información de la categoría

  TaskModel({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    required this.completada,
    required this.enProgreso,
    this.categoriaId,
    this.workspaceId,
    this.asignadoA,
    this.fechaVencimiento,
    this.usuarioInfo,
    this.asignadoInfo,
    this.categoriaInfo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      prioridad: json['prioridad'] ?? 'M',
      estado: json['estado'] ?? 'TODO',
      completada: json['completada'] ?? false,
      enProgreso: json['en_progreso'] ?? false,
      categoriaId: json['categoria'],
      workspaceId: json['workspace'],
      asignadoA: json['asignado_a'],
      fechaVencimiento: json['fecha_vencimiento'] != null 
          ? DateTime.tryParse(json['fecha_vencimiento']) 
          : null,
      usuarioInfo: json['usuario_info'] as Map<String, dynamic>?,
      asignadoInfo: json['asignado_info'] as Map<String, dynamic>?,
      categoriaInfo: json['categoria_info'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad,
      'estado': estado,
      'completada': completada,
      'en_progreso': enProgreso,
      'categoria': categoriaId,
      'workspace': workspaceId,
      'asignado_a': asignadoA,
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      if (usuarioInfo != null) 'usuario_info': usuarioInfo,
      if (asignadoInfo != null) 'asignado_info': asignadoInfo,
      if (categoriaInfo != null) 'categoria_info': categoriaInfo,
    };
  }

  TaskModel copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? prioridad,
    String? estado,
    bool? completada,
    bool? enProgreso,
    int? categoriaId,
    int? workspaceId,
    int? asignadoA,
    DateTime? fechaVencimiento,
    Map<String, dynamic>? usuarioInfo,
    Map<String, dynamic>? asignadoInfo,
    Map<String, dynamic>? categoriaInfo,
  }) {
    return TaskModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      completada: completada ?? this.completada,
      enProgreso: enProgreso ?? this.enProgreso,
      categoriaId: categoriaId ?? this.categoriaId,
      workspaceId: workspaceId ?? this.workspaceId,
      asignadoA: asignadoA ?? this.asignadoA,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      usuarioInfo: usuarioInfo ?? this.usuarioInfo,
      asignadoInfo: asignadoInfo ?? this.asignadoInfo,
      categoriaInfo: categoriaInfo ?? this.categoriaInfo,
    );
  }
}