class WorkspaceModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String codigo;
  final int admin;
  final int cantidadMiembros;
  final bool esAdmin;
  final DateTime creadoEn;

  WorkspaceModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.codigo,
    required this.admin,
    required this.cantidadMiembros,
    required this.esAdmin,
    required this.creadoEn,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      codigo: json['codigo'] ?? '',
      admin: json['admin'] ?? 0,
      cantidadMiembros: json['cantidad_miembros'] ?? 1,
      esAdmin: json['es_admin'] ?? false,
      creadoEn: DateTime.parse(json['creado_en']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'descripcion': descripcion};
  }
}
