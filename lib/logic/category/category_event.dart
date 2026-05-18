part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryLoadEvent extends CategoryEvent {}

class CategoryCreateEvent extends CategoryEvent {
  final Map<String, dynamic> categoryData;
  const CategoryCreateEvent(this.categoryData);

  @override
  List<Object?> get props => [categoryData];
}

class CategoryUpdateEvent extends CategoryEvent {
  final int id;
  final Map<String, dynamic> categoryData;
  const CategoryUpdateEvent(this.id, this.categoryData);

  @override
  List<Object?> get props => [id, categoryData];
}

class CategoryDeleteEvent extends CategoryEvent {
  final int id;
  const CategoryDeleteEvent(this.id);

  @override
  List<Object?> get props => [id];
}
