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