import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {}

class ProfileUpdateEvent extends ProfileEvent {
  final Map<String, dynamic> perfilData;

  const ProfileUpdateEvent(this.perfilData);

  @override
  List<Object?> get props => [perfilData];
}
