// lib/logic/auth/auth_state.dart

part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final int userId;
  final String username;

  const AuthAuthenticated({
    required this.token,
    required this.userId,
    required this.username,
  });

  @override
  List<Object?> get props => [token, userId, username];
}

class AuthUnauthenticated extends AuthState {}

// ✅ ESTADOS PARA REGISTRO
class AuthRegisterSuccess extends AuthState {
  final String message;
  const AuthRegisterSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class AuthRegisterError extends AuthState {
  final String message;
  final Map<String, dynamic>? errors;
  const AuthRegisterError({required this.message, this.errors});
  @override
  List<Object?> get props => [message, errors];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}