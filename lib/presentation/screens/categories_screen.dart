import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/category_model.dart';
import '../../logic/category/category_bloc.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(CategoryLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryLoaded) {
            if (state.categorias.isEmpty) {
              return const Center(child: Text('No hay categorias'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.categorias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final categoria = state.categorias[index];
                return _CategoryTile(categoria: categoria);
              },
            );
          }

          if (state is CategoryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CategoryBloc>().add(CategoryLoadEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? categoria}) {
    final categoryBloc = context.read<CategoryBloc>();
    final nameController = TextEditingController(text: categoria?.nombre ?? '');
    var selectedColor = categoria?.color ?? _categoryColors.first;
    final isEditing = categoria != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar categoria' : 'Nueva categoria'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categoryColors.map((color) {
                      final selected = color == selectedColor;
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setDialogState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _colorFromHex(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? Colors.black87
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final data = {'nombre': name, 'color': selectedColor};
                    if (isEditing) {
                      categoryBloc.add(CategoryUpdateEvent(categoria.id, data));
                    } else {
                      categoryBloc.add(CategoryCreateEvent(data));
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: Text(isEditing ? 'Guardar' : 'Crear'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(nameController.dispose);
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel categoria;

  const _CategoryTile({required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _colorFromHex(categoria.color),
          child: const Icon(Icons.label, color: Colors.white),
        ),
        title: Text(categoria.nombre),
        subtitle: Text(categoria.color),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              color: Colors.blue,
              onPressed: () {
                final state = context.findAncestorStateOfType<
                    _CategoriesScreenState>();
                state?._showCategoryDialog(context, categoria: categoria);
              },
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar categoria'),
          content: Text('¿Eliminar "${categoria.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.read<CategoryBloc>().add(
                      CategoryDeleteEvent(categoria.id),
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

const _categoryColors = [
  '#10b981',
  '#14b8a6',
  '#3b82f6',
  '#6366f1',
  '#8b5cf6',
  '#ec4899',
  '#ef4444',
  '#f59e0b',
  '#84cc16',
  '#64748b',
];

Color _colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '');
  final value = int.tryParse('ff$normalized', radix: 16);
  return Color(value ?? 0xff10b981);
}
