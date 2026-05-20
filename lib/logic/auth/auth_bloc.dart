// lib/logic/auth/auth_bloc.dart

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
    on<AuthRegisterEvent>(_onRegister);  // ✅ AÑADE ESTO
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final loginResponse = await _authRepository.login(event.username, event.password);

      if (loginResponse != null && loginResponse.token.isNotEmpty) {
        emit(AuthAuthenticated(
          token: loginResponse.token,
          userId: loginResponse.userId,
          username: event.username,
        ));
      } else {
        emit(const AuthError(message: 'Usuario o contraseña incorrectos'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error de conexión: $e'));
    }
  }

  // ✅ MÉTODO DE REGISTRO
  Future<void> _onRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final response = await _authRepository.register(
      username: event.username,
      email: event.email,
      password: event.password,
      password2: event.password2,
    );
    
    if (response.success) {
      emit(AuthRegisterSuccess(message: response.message));
    } else {
      emit(AuthRegisterError(message: response.message, errors: response.errors));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final sessionData = await _authRepository.getSessionData();

    if (sessionData != null) {
      emit(AuthAuthenticated(
        token: sessionData['token'],
        userId: sessionData['userId'],
        username: sessionData['username'] ?? '',
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}