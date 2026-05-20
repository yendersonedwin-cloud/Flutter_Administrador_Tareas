import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/workspace_model.dart';
import '../../data/repositories/workspace_repository.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRepository repository;

  WorkspaceBloc({required this.repository}) : super(WorkspaceInitial()) {

    on<WorkspaceLoadEvent>((event, emit) async {
      emit(WorkspaceLoading());
      try {
        final workspaces = await repository.getWorkspaces();
        emit(WorkspaceLoaded(workspaces: workspaces));
      } catch (e) {
        emit(WorkspaceError(message: e.toString()));
      }
    });

    on<WorkspaceCreateEvent>((event, emit) async {
      emit(WorkspaceLoading());
      try {
        await repository.createWorkspace(event.workspaceData);
        final workspaces = await repository.getWorkspaces();
        emit(WorkspaceLoaded(workspaces: workspaces));
      } catch (e) {
        emit(WorkspaceError(message: e.toString()));
      }
    });

    // ← ESTE ERA EL QUE FALTABA
    on<WorkspaceJoinEvent>((event, emit) async {
      emit(WorkspaceLoading());
      try {
        final exito = await repository.joinWorkspace(event.codigo);
        if (exito) {
          final workspaces = await repository.getWorkspaces();
          emit(WorkspaceLoaded(workspaces: workspaces));
        } else {
          emit(const WorkspaceError(message: 'Código incorrecto o workspace no encontrado'));
        }
      } catch (e) {
        emit(WorkspaceError(message: e.toString()));
      }
    });

    on<WorkspaceDeleteEvent>((event, emit) async {
      emit(WorkspaceLoading());
      try {
        await repository.deleteWorkspace(event.id);
        final workspaces = await repository.getWorkspaces();
        emit(WorkspaceLoaded(workspaces: workspaces));
      } catch (e) {
        emit(WorkspaceError(message: e.toString()));
      }
    });
  }
}