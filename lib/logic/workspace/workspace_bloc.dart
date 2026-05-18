import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/workspace_model.dart';
import '../../data/repositories/workspace_repository.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRepository _workspaceRepository;

  WorkspaceBloc({required WorkspaceRepository workspaceRepository})
      : _workspaceRepository = workspaceRepository,
        super(WorkspaceInitial()) {
    on<WorkspaceLoadEvent>(_onLoadWorkspaces);
    on<WorkspaceCreateEvent>(_onCreateWorkspace);
  }

  Future<void> _onLoadWorkspaces(
    WorkspaceLoadEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(WorkspaceLoading());
    try {
      final workspaces = await _workspaceRepository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces: workspaces));
    } catch (e) {
      emit(WorkspaceError(message: 'Error al cargar workspaces: $e'));
    }
  }

  Future<void> _onCreateWorkspace(
    WorkspaceCreateEvent event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      await _workspaceRepository.createWorkspace(event.workspaceData);
      final workspaces = await _workspaceRepository.getWorkspaces();
      emit(WorkspaceLoaded(workspaces: workspaces));
    } catch (e) {
      emit(WorkspaceError(message: 'Error al crear workspace: $e'));
    }
  }
}
