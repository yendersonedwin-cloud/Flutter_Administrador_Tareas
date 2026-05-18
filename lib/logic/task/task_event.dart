part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskLoadEvent extends TaskEvent {}

class TaskCreateEvent extends TaskEvent {
  final Map<String, dynamic> tareaData;

  const TaskCreateEvent({required this.tareaData});

  @override
  List<Object?> get props => [tareaData];
}

class TaskUpdateEvent extends TaskEvent {
  final int id;
  final Map<String, dynamic> tareaData;

  const TaskUpdateEvent({required this.id, required this.tareaData});

  @override
  List<Object?> get props => [id, tareaData];
}

class TaskDeleteEvent extends TaskEvent {
  final int id;

  const TaskDeleteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class TaskToggleCompleteEvent extends TaskEvent {
  final int id;
  final bool completada;

  const TaskToggleCompleteEvent(this.id, this.completada);

  @override
  List<Object?> get props => [id, completada];
}

class TaskLogoutEvent extends TaskEvent {}
