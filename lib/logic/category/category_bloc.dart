import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(CategoryInitial()) {
    on<CategoryLoadEvent>(_onLoadCategories);
    on<CategoryCreateEvent>(_onCreateCategory);
    on<CategoryUpdateEvent>(_onUpdateCategory);
    on<CategoryDeleteEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    CategoryLoadEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    try {
      final categorias = await _categoryRepository.getCategorias();
      emit(CategoryLoaded(categorias: categorias));
    } catch (e) {
      emit(CategoryError(message: 'Error al cargar categorias: $e'));
    }
  }

  Future<void> _onCreateCategory(
    CategoryCreateEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.createCategoria(event.categoryData);
      add(CategoryLoadEvent());
    } catch (e) {
      emit(CategoryError(message: 'Error al crear categoria: $e'));
    }
  }

  Future<void> _onUpdateCategory(
    CategoryUpdateEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.updateCategoria(event.id, event.categoryData);
      add(CategoryLoadEvent());
    } catch (e) {
      emit(CategoryError(message: 'Error al actualizar categoria: $e'));
    }
  }

  Future<void> _onDeleteCategory(
    CategoryDeleteEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.deleteCategoria(event.id);
      add(CategoryLoadEvent());
    } catch (e) {
      emit(CategoryError(message: 'Error al eliminar categoria: $e'));
    }
  }
}
