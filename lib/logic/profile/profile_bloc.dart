import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<ProfileLoadEvent>(_onLoadProfile);
    on<ProfileUpdateEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final perfil = await _profileRepository.getMiPerfil();
      emit(ProfileLoaded(perfil: perfil));
    } catch (e) {
      emit(ProfileError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfile(
    ProfileUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(ProfileLoading());
    try {
      final perfilActualizado =
          await _profileRepository.updatePerfil(event.perfilData);
      emit(ProfileLoaded(perfil: perfilActualizado));
    } catch (e) {
      emit(ProfileError(message: 'No se pudo actualizar el perfil: $e'));
      if (currentState is ProfileLoaded) {
        emit(currentState);
      }
    }
  }
}
