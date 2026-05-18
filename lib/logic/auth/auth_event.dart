part of 'auth_bloc.dart';

// Eventos de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Evento para iniciar sesión
class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginEvent({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

// Evento para cerrar sesión
class AuthLogoutEvent extends AuthEvent {}

// Evento para verificar si ya hay sesión guardada
class AuthCheckStatusEvent extends AuthEvent {}
