import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../logic/category/category_bloc.dart';

class CategorySectionView extends StatelessWidget {
  const CategorySectionView({super.key});

  // Helper útil para convertir los strings Hex de Django a un Color de Flutter
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera de la sección
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categorías',
              style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen, size: 26),
              onPressed: () => _showQuickCreateCategoryPanel(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Listado Dinámico Reactivo
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading || state is CategoryInitial) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
            }
            if (state is CategoryLoaded) {
              if (state.categorias.isEmpty) {
                return const Center(
                  child: Text('No hay categorías creadas', style: TextStyle(color: AppColors.textMuted)),
                );
              }
              return Column(
                children: state.categorias.map((CategoryModel cat) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(radius: 6, backgroundColor: _parseHexColor(cat.color)),
                      title: Text(cat.nombre, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textDark)),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
                        color: AppColors.surfaceWhite,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) {
                          if (value == 'eliminar') _showDeleteCategoryDialog(context, cat.id, cat.nombre);
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'eliminar',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                SizedBox(width: 8),
                                Text('Eliminar', style: TextStyle(color: AppColors.textDark)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                  );
                }).toList(),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  // Diálogo seguro de borrado
  void _showDeleteCategoryDialog(BuildContext context, int categoryId, String nombreCategoria) {
    final categoryBloc = context.read<CategoryBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(child: Text('¿Eliminar "$nombreCategoria"?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
        content: const Text('Si eliminas esta categoría, las tareas vinculadas a ella no se borrarán, pero quedarán marcadas como "Sin categoría".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () {
              categoryBloc.add(CategoryDeleteEvent(categoryId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Modal para crear nueva categoría con paleta de colores
  void _showQuickCreateCategoryPanel(BuildContext context) {
    final nameController = TextEditingController();
    final categoryBloc = context.read<CategoryBloc>();
    final List<String> coloresDisponibles = ['#00B074', '#FF4D4F', '#FF9922', '#1890FF', '#722ED1', '#EB2F96'];
    String colorSeleccionado = coloresDisponibles[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(top: 20, left: 24, right: 24, bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nueva Categoría Rápida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: const InputDecoration(labelText: 'Nombre de la categoría', labelStyle: TextStyle(color: AppColors.textMuted), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Selecciona un color:', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: coloresDisponibles.map((colorHex) {
                      final isSelected = colorSeleccionado == colorHex;
                      return GestureDetector(
                        onTap: () => setSheetState(() => colorSeleccionado = colorHex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? _parseHexColor(colorHex) : Colors.transparent, width: 2)),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: _parseHexColor(colorHex),
                            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        final data = {'nombre': nameController.text.trim(), 'color': colorSeleccionado};
                        categoryBloc.add(CategoryCreateEvent(data));
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Crear Categoría', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
