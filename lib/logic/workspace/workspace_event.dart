part of 'workspace_bloc.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class WorkspaceLoadEvent extends WorkspaceEvent {}

class WorkspaceCreateEvent extends WorkspaceEvent {
  final Map<String, dynamic> workspaceData;

  const WorkspaceCreateEvent({required this.workspaceData});

  @override
  List<Object?> get props => [workspaceData];
}

class WorkspaceJoinEvent extends WorkspaceEvent {
  final String codigo;

  const WorkspaceJoinEvent({required this.codigo});

  @override
  List<Object?> get props => [codigo];
}

class WorkspaceDeleteEvent extends WorkspaceEvent {
  final int id;

  const WorkspaceDeleteEvent({required this.id});

  @override
  List<Object?> get props => [id];
}