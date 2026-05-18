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
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }
        if (state is TaskLoaded) {
          if (state.tareas.isEmpty) {
            return const Center(child: Text('No hay tareas registradas', style: TextStyle(color: AppColors.textMuted)));
          }

          final DateTime hoy = DateTime.now();
          final tareasFiltradas = state.tareas.where((tarea) {
            if (activeFilter == 'Hoy') {
              if (tarea.fechaVencimiento == null) return false;
              return tarea.fechaVencimiento!.year == hoy.year &&
                     tarea.fechaVencimiento!.month == hoy.month &&
                     tarea.fechaVencimiento!.day == hoy.day;
            } 
            if (activeFilter == 'Próximas') {
              if (tarea.fechaVencimiento == null) return false;
              final fechaTareaSoloDia = DateTime(tarea.fechaVencimiento!.year, tarea.fechaVencimiento!.month, tarea.fechaVencimiento!.day);
              final hoySoloDia = DateTime(hoy.year, hoy.month, hoy.day);
              return fechaTareaSoloDia.isAfter(hoySoloDia);
            }
            return true;
          }).toList();

          if (tareasFiltradas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No hay tareas para "$activeFilter"',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),
            );
          }

          return Column(
            children: tareasFiltradas.map((tarea) => _buildTaskItem(context, tarea)).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel tarea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: tarea.completada,
          activeColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) {
            if (val != null && tarea.id != null) {
              context.read<TaskBloc>().add(TaskToggleCompleteEvent(tarea.id!, val));
            }
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tarea.titulo,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  decoration: tarea.completada ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (tarea.categoriaId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _parseHexColor(tarea.colorCategoria).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tarea.nombreCategoria,
                  style: TextStyle(
                    color: _parseHexColor(tarea.colorCategoria),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: tarea.descripcion.isNotEmpty
            ? Text(tarea.descripcion, style: const TextStyle(color: AppColors.textMuted, fontSize: 13))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriorityChip(tarea.prioridad),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
              onPressed: () => _showEditTaskPanel(context, tarea),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
              onPressed: () => _showDeleteDialog(context, tarea.id!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String? prioridad) {
    final valorPrioridad = prioridad ?? 'Media';
    Color bg = AppColors.priorityMedium;
    Color txt = AppColors.textMedium;
    if (valorPrioridad == 'Alta') { bg = AppColors.priorityHigh; txt = AppColors.textHigh; }
    if (valorPrioridad == 'Baja') { bg = AppColors.priorityLow; txt = AppColors.textLow; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(valorPrioridad, style: TextStyle(color: txt, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _showDeleteDialog(BuildContext context, int taskId) {
    final taskBloc = context.read<TaskBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('¿Eliminar tarea?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Esta acción quitará la tarea por completo de tu base de datos de Django.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              taskBloc.add(TaskDeleteEvent(taskId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditTaskPanel(BuildContext context, TaskModel tarea) {
    final titleController = TextEditingController(text: tarea.titulo);
    final descController = TextEditingController(text: tarea.descripcion);
    String prioridadSeleccionada = tarea.prioridad;
    int? categoriaSeleccionadaId = tarea.categoriaId; 
    final taskBloc = context.read<TaskBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final categoryState = context.read<CategoryBloc>().state;
        List<CategoryModel> GraphicCategories = [];
        if (categoryState is CategoryLoaded) {
          GraphicCategories = categoryState.categorias;
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24, left: 24, right: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Editar Detalles de Tarea', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: const InputDecoration(labelText: 'Título de la tarea', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Categoría vinculada:', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    value: GraphicCategories.any((c) => c.id == categoriaSeleccionadaId) ? categoriaSeleccionadaId : null,
                    dropdownColor: AppColors.surfaceWhite,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Ninguna (Dejar vacía)', style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                      ),
                      ...GraphicCategories.map((cat) {
                        return DropdownMenuItem<int?>(
                          value: cat.id,
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: _parseHexColor(cat.color))),
                              const SizedBox(width: 8),
                              Text(cat.nombre),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (int? nuevoId) {
                      setSheetState(() => categoriaSeleccionadaId = nuevoId);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Prioridad:', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Baja', 'Media', 'Alta'].map((prio) {
                      final isSelected = prioridadSeleccionada == prio;
                      return ChoiceChip(
                        label: Text(prio),
                        selected: isSelected,
                        selectedColor: AppColors.primaryGreen,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold),
                        onSelected: (bool selected) {
                          if (selected) {
                            setSheetState(() => prioridadSeleccionada = prio);
                          }
                        },
                      );
                    }).toList(),
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
                          'prioridad': prioridadSeleccionada == 'Alta' ? 'A' : (prioridadSeleccionada == 'Baja' ? 'B' : 'M'),
                          'estado': tarea.estado,
                          'completada': tarea.completada,
                          'en_progreso': tarea.enProgreso,
                          'categoria': categoriaSeleccionadaId,
                        };
                        taskBloc.add(TaskUpdateEvent(id: tarea.id!, tareaData: dataActualizada));
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Actualizar Tarea', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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