import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/workspace_model.dart';
import '../../data/repositories/workspace_repository.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final WorkspaceRepository repository;

  WorkspaceBloc({required this.repository}) : super(WorkspaceInitial()) {
    
    // Cargar equipos
    on<WorkspaceLoadEvent>((event, emit) async {
      emit(WorkspaceLoading());
      try {
        final workspaces = await repository.getWorkspaces();
        emit(WorkspaceLoaded(workspaces: workspaces));
      } catch (e) {
        emit(WorkspaceError(message: e.toString()));
      }
    });

    // 🚀 NUEVO: Manejador para CREAR un Workspace
    on<WorkspaceCreateEvent>((event, emit) async {
      emit(WorkspaceLoading());
      try {
        // Envia el Map con el nombre/datos del formulario a Django
        await repository.createWorkspace(event.workspaceData); 
        
        // Refrescamos la lista automáticamente tras crear exitosamente
        final workspaces = await repository.getWorkspaces();
        emit(WorkspaceLoaded(workspaces: workspaces));
      } catch (e) {
        emit(WorkspaceError(message: e.toString()));
      }
    });

    // Eliminar equipos
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