import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/category_model.dart';
import '../../../logic/task/task_bloc.dart';
import '../../../logic/category/category_bloc.dart';

class TaskListView extends StatelessWidget {
  final String activeFilter;

  const TaskListView({super.key, required this.activeFilter});

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (state is TaskLoaded) {
          // 🚀 FILTRO PARA COMPLETADAS (viene del drawer)
          if (activeFilter == 'Completadas') {
            final completadas = state.tareas.where((t) => t.completada).toList();
            if (completadas.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No tienes tareas completadas 🎉',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                  ),
                ),
              );
            }
            return _buildListaCompletadas(completadas);
          }

          // 🚀 FILTRO PARA PENDIENTES
          final tareasPendientes = state.tareas
              .where((t) => !t.completada)
              .toList();

          if (tareasPendientes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No tienes tareas pendientes 🎉',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
              ),
            );
          }

          // Aplicar filtros de pestañas ('Todas', 'Hoy', 'Próximas')
          List<TaskModel> filteredTasks = tareasPendientes;
          final now = DateTime.now();
          final todayStr =
              "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

          if (activeFilter == 'Hoy') {
            filteredTasks = tareasPendientes.where((task) {
              if (task.fechaVencimiento == null) return true;
              final tStr =
                  "${task.fechaVencimiento!.year}-"
                  "${task.fechaVencimiento!.month.toString().padLeft(2, '0')}-"
                  "${task.fechaVencimiento!.day.toString().padLeft(2, '0')}";
              return tStr == todayStr;
            }).toList();
          } else if (activeFilter == 'Próximas') {
            filteredTasks = tareasPendientes.where((task) {
              if (task.fechaVencimiento == null) return false;
              final tStr =
                  "${task.fechaVencimiento!.year}-${task.fechaVencimiento!.month.toString().padLeft(2, '0')}-${task.fechaVencimiento!.day.toString().padLeft(2, '0')}";
              return tStr != todayStr && task.fechaVencimiento!.isAfter(now);
            }).toList();
          }
          
          if (filteredTasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No hay tareas para el filtro: $activeFilter',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final tarea = filteredTasks[index];
              String labelPrioridad = tarea.prioridad == 'A'
                  ? 'Alta'
                  : (tarea.prioridad == 'B' ? 'Baja' : 'Media');
              Color colorPrioridad = tarea.prioridad == 'A'
                  ? Colors.red
                  : (tarea.prioridad == 'B' ? Colors.blue : Colors.orange);

              String catName = 'Sin categoría';
              Color catColor = AppColors.primaryGreen;
              if (tarea.categoriaInfo != null) {
                catName = tarea.categoriaInfo!['nombre'] ?? 'Sin categoría';
                catColor = _parseHexColor(
                  tarea.categoriaInfo!['color_hex'] ?? '#4E9F3D',
                );
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: tarea.completada,
                      activeColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (bool? value) {
                        if (value != null) {
                          context.read<TaskBloc>().add(
                            TaskToggleCompleteEvent(tarea.id!, value),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tarea.titulo,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (tarea.descripcion.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                tarea.descripcion,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  catName,
                                  style: TextStyle(
                                    color: catColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorPrioridad.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  labelPrioridad,
                                  style: TextStyle(
                                    color: colorPrioridad,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') {
                          _showEditBottomSheet(context, tarea);
                        } else if (val == 'delete') {
                          context.read<TaskBloc>().add(
                            TaskDeleteEvent(tarea.id!),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.textMuted,
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 18,
                                color: AppColors.textDark,
                              ),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }

        if (state is TaskError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return const Center(child: Text('Estado desconocido'));
      },
    );
  }

  // 🚀 MÉTODO PARA MOSTRAR TAREAS COMPLETADAS CON TÍTULO
  Widget _buildListaCompletadas(List<TaskModel> completadas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ TÍTULO DE LA SECCIÓN COMPLETADAS
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tareas Completadas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Historial de tareas finalizadas',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Lista de tareas completadas
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: completadas.length,
          itemBuilder: (context, index) {
            final tarea = completadas[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen.withOpacity(0.5),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarea.titulo,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        if (tarea.descripcion.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              tarea.descripcion,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (tarea.fechaVencimiento != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Completada: ${tarea.fechaVencimiento!.day}/${tarea.fechaVencimiento!.month}/${tarea.fechaVencimiento!.year}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.undo, color: AppColors.textMuted, size: 18),
                    tooltip: 'Restaurar tarea',
                    onPressed: () {
                      context.read<TaskBloc>().add(
                        TaskToggleCompleteEvent(tarea.id!, false),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showEditBottomSheet(BuildContext context, TaskModel tarea) {
    final taskBloc = context.read<TaskBloc>();
    final categoryState = context.read<CategoryBloc>().state;
    List<CategoryModel> categorias = [];
    if (categoryState is CategoryLoaded) {
      categorias = categoryState.categorias;
    }

    final titleController = TextEditingController(text: tarea.titulo);
    final descController = TextEditingController(text: tarea.descripcion);
    String prioridadSeleccionada = tarea.prioridad == 'A'
        ? 'Alta'
        : (tarea.prioridad == 'B' ? 'Baja' : 'Media');
    int? categoriaSeleccionadaId = tarea.categoriaId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar Tarea',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Título de la tarea',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Descripción (opcional)',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Prioridad',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Baja', 'Media', 'Alta'].map((p) {
                      final isSel = prioridadSeleccionada == p;
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => prioridadSeleccionada = p),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primaryGreen
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            p,
                            style: TextStyle(
                              color: isSel ? Colors.white : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Categoría',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: categoriaSeleccionadaId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text(
                      'Selecciona una categoría',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    items: categorias.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(
                          cat.nombre,
                          style: const TextStyle(color: AppColors.textDark),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setModalState(() => categoriaSeleccionadaId = val),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        final Map<String, dynamic> dataActualizada = {
                          'titulo': titleController.text.trim(),
                          'descripcion': descController.text.trim(),
                          'prioridad': prioridadSeleccionada == 'Alta'
                              ? 'A'
                              : (prioridadSeleccionada == 'Baja' ? 'B' : 'M'),
                          'estado': tarea.estado,
                          'completada': tarea.completada,
                          'en_progreso': tarea.enProgreso,
                          'categoria': categoriaSeleccionadaId,
                        };
                        taskBloc.add(
                          TaskUpdateEvent(
                            id: tarea.id!,
                            tareaData: dataActualizada,
                          ),
                        );
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Actualizar Tarea',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}