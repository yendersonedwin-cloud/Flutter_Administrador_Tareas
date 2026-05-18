part of 'auth_bloc.dart';

// Estado base de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Estado inicial - cargando
class AuthInitial extends AuthState {}

// Cargando (verificando token o logueando)
class AuthLoading extends AuthState {}

// Autenticado exitosamente
class AuthAuthenticated extends AuthState {
  final String token;

  const AuthAuthenticated({required this.token});

  @override
  List<Object?> get props => [token];
}

// No autenticado (sin token o token inválido)
class AuthUnauthenticated extends AuthState {}

// Error en autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
