class UserModel {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}

class PerfilModel {
  final int id;
  final UserModel usuario;
  final String? imagen;
  final String bio;

  PerfilModel({
    required this.id,
    required this.usuario,
    this.imagen,
    required this.bio,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    return PerfilModel(
      id: json['id'],
      usuario: UserModel.fromJson(json['usuario']),
      imagen: json['imagen'],
      bio: json['bio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'bio': bio};
  }
}
