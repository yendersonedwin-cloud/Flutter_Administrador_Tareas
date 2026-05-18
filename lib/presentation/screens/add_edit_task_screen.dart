import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../../logic/category/category_bloc.dart';
import '../../logic/task/task_bloc.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _prioridad = 'Media';
  DateTime? _fechaVencimiento;
  int? _categoriaId;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(CategoryLoadEvent());
    final task = widget.task;
    if (task != null) {
      _tituloController.text = task.titulo;
      _descripcionController.text = task.descripcion;
      _prioridad = task.prioridad;
      _fechaVencimiento = task.fechaVencimiento;
      _categoriaId = task.categoriaId;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Titulo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El titulo es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripcion',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _prioridad,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: const [
                DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                DropdownMenuItem(value: 'Media', child: Text('Media')),
                DropdownMenuItem(value: 'Alta', child: Text('Alta')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _prioridad = value;
                });
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const ListTile(
                    leading: Icon(Icons.category),
                    title: Text('Cargando categorias...'),
                  );
                }

                if (state is CategoryError) {
                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('No se pudieron cargar las categorias'),
                    subtitle: Text(state.message),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<CategoryBloc>().add(CategoryLoadEvent());
                      },
                    ),
                  );
                }

                final categorias = state is CategoryLoaded
                    ? state.categorias
                    : [];
                final selectedCategoryId = categorias.any(
                  (categoria) => categoria.id == _categoriaId,
                )
                    ? _categoriaId
                    : null;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        hint: const Text('Sin categoria'),
                        items: categorias.map((categoria) {
                          return DropdownMenuItem<int>(
                            value: categoria.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _colorFromHex(categoria.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(categoria.nombre)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _categoriaId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Quitar categoria',
                      onPressed: _categoriaId == null
                          ? null
                          : () {
                              setState(() {
                                _categoriaId = null;
                              });
                            },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _fechaVencimiento == null
                    ? 'Sin fecha de vencimiento'
                    : 'Vence: ${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _fechaVencimiento == null
                    ? null
                    : () {
                        setState(() {
                          _fechaVencimiento = null;
                        });
                      },
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _fechaVencimiento ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _fechaVencimiento = date;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Actualizar Tarea' : 'Crear Tarea',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final task = widget.task;
    final taskData = {
      'titulo': _tituloController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'prioridad': _mapPrioridadApi(_prioridad),
      'estado': task?.estado ?? 'TODO',
      'completada': task?.completada ?? false,
      'en_progreso': task?.enProgreso ?? false,
      if (_fechaVencimiento != null)
        'fecha_vencimiento': _fechaVencimiento!.toIso8601String().split('T')[0],
      if (task != null || _categoriaId != null) 'categoria': _categoriaId,
    };

    if (task != null) {
      context.read<TaskBloc>().add(
        TaskUpdateEvent(id: task.id!, tareaData: taskData),
      );
    } else {
      context.read<TaskBloc>().add(TaskCreateEvent(tareaData: taskData));
    }

    Navigator.pop(context);
  }

  String _mapPrioridadApi(String prioridad) {
    switch (prioridad) {
      case 'Alta':
        return 'A';
      case 'Baja':
        return 'B';
      case 'Media':
      default:
        return 'M';
    }
  }

  Color _colorFromHex(String hex) {
    final normalized = hex.replaceFirst('#', '');
    final value = int.tryParse('ff$normalized', radix: 16);
    return Color(value ?? 0xff10b981);
  }
}
