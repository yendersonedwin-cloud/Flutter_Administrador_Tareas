class CategoryModel {
  final int id;
  final String nombre;
  final String color;

  CategoryModel({required this.id, required this.nombre, required this.color});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      color: json['color'] ?? '#10b981',
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'color': color};
  }

  CategoryModel copyWith({int? id, String? nombre, String? color}) {
    return CategoryModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
    );
  }
}
