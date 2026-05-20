import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(TaskInitial()) {
    on<TaskLoadEvent>(_onLoadTasks);
    on<TaskCreateEvent>(_onCreateTask);
    on<TaskUpdateEvent>(_onUpdateTask);
    on<TaskDeleteEvent>(_onDeleteTask);
    on<TaskToggleCompleteEvent>(_onToggleComplete);
    on<TaskLogoutEvent>(_onLogout);
  }

  Future<void> _onLoadTasks(
    TaskLoadEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());

    try {
      final tareas = await _taskRepository.getTareas();
      emit(TaskLoaded(tareas: tareas));
    } catch (e) {
      emit(TaskError(message: 'Error al cargar tareas: $e'));
    }
  }

  Future<void> _onCreateTask(
    TaskCreateEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    try {
      final nuevaTarea = await _taskRepository.createTarea(event.tareaData);

      if (currentState is TaskLoaded) {
        final nuevasTareas = [nuevaTarea, ...currentState.tareas];
        emit(TaskLoaded(tareas: nuevasTareas));
      } else {
        final tareas = await _taskRepository.getTareas();
        emit(TaskLoaded(tareas: tareas));
      }
    } catch (e) {
      emit(TaskError(message: 'Error al crear tarea: $e'));
      if (currentState is TaskLoaded) emit(currentState);
    }
  }

  Future<void> _onUpdateTask(
    TaskUpdateEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    try {
      final tareaActualizada = await _taskRepository.updateTarea(
        event.id,
        event.tareaData,
      );

      if (currentState is TaskLoaded) {
        final nuevasTareas = currentState.tareas.map((tarea) {
          return tarea.id == event.id ? tareaActualizada : tarea;
        }).toList();
        emit(TaskLoaded(tareas: nuevasTareas));
      } else {
        final tareas = await _taskRepository.getTareas();
        emit(TaskLoaded(tareas: tareas));
      }
    } catch (e) {
      emit(TaskError(message: 'Error al actualizar tarea: $e'));
      if (currentState is TaskLoaded) emit(currentState);
    }
  }

  Future<void> _onDeleteTask(
    TaskDeleteEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        await _taskRepository.deleteTarea(event.id);
        final nuevasTareas = currentState.tareas
            .where((tarea) => tarea.id != event.id)
            .toList();
        emit(TaskLoaded(tareas: nuevasTareas));
      } catch (e) {
        emit(TaskError(message: 'Error al eliminar tarea: $e'));
        emit(currentState);
      }
    }
  }

// Agrega esta función al final de lib/logic/task/task_bloc.dart
Future<void> _onToggleComplete(
  TaskToggleCompleteEvent event,
  Emitter<TaskState> emit,
) async {
  final currentState = state;
  if (currentState is TaskLoaded) {
    try {
      // 🚀 Llamamos al repositorio para actualizar en Django
      final tareaActualizada = await _taskRepository.toggleComplete(
        event.id,
        event.completada,
      );
      // Actualizamos el estado local reactivamente sin recargar
      final nuevasTareas = currentState.tareas.map((tarea) {
        return tarea.id == event.id ? tareaActualizada : tarea;
      }).toList();
      emit(TaskLoaded(tareas: nuevasTareas));
    } catch (e) {
      emit(TaskError(message: 'Error al cambiar estado de tarea: $e'));
      // Revertimos el estado si hay error
      emit(currentState);
    }
  }
}
  Future<void> _onLogout(TaskLogoutEvent event, Emitter<TaskState> emit) async {
    emit(TaskInitial());
  }
}
