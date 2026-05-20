// lib/logic/auth/auth_event.dart

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;
  const AuthLoginEvent({required this.username, required this.password});
  @override
  List<Object?> get props => [username, password];
}

// ✅ AÑADE ESTE EVENTO
class AuthRegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String password2;
  
  const AuthRegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.password2,
  });
  
  @override
  List<Object?> get props => [username, email, password, password2];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}