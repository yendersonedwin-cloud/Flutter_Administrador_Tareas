import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
  }

  // Manejar login
  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final token = await _authRepository.login(event.username, event.password);

      if (token != null && token.isNotEmpty) {
        emit(AuthAuthenticated(token: token));
      } else {
        emit(const AuthError(message: 'Usuario o contraseña incorrectos'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error de conexión: $e'));
    }
  }

  // Manejar logout
  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  // Verificar si hay sesión guardada (para mantener login al reiniciar app)
  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      // Si tenemos token pero no lo tenemos en memoria, lo recuperamos
      // Por ahora solo verificamos que hay sesión
      emit(const AuthAuthenticated(token: ''));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
