import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_colors.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/category/category_bloc.dart';
import '../../../logic/task/task_bloc.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onFilterChanged;
  final String activeFilter;
  final VoidCallback? onEquiposTap;  // ✅ Callback para navegar a equipos
  final VoidCallback? onPerfilTap;   // ✅ Callback para navegar a perfil

  const CustomDrawer({
    super.key,
    required this.onFilterChanged,
    required this.activeFilter,
    this.onEquiposTap,
    this.onPerfilTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header del Drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.task_alt,
                      color: AppColors.primaryGreen,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TaskFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String username = 'Usuario';
                      if (state is AuthAuthenticated) {
                        username = state.username.isNotEmpty ? state.username : 'Usuario';
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Opciones del menú
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Sección: Mi Día
                  _buildDrawerItem(
                    icon: Icons.wb_sunny,
                    title: 'Mi Día',
                    filterValue: 'Hoy',
                    isActive: activeFilter == 'Hoy',
                    onTap: () => onFilterChanged('Hoy'),
                  ),
                  // Sección: Próximas Tareas
                  _buildDrawerItem(
                    icon: Icons.calendar_today,
                    title: 'Próximas Tareas',
                    filterValue: 'Próximas',
                    isActive: activeFilter == 'Próximas',
                    onTap: () => onFilterChanged('Próximas'),
                  ),
                  // Sección: Completadas
                  _buildDrawerItem(
                    icon: Icons.check_circle_outline,
                    title: 'Completadas',
                    filterValue: 'Completadas',
                    isActive: activeFilter == 'Completadas',
                    onTap: () => onFilterChanged('Completadas'),
                  ),
                  const Divider(height: 32, thickness: 1),
                  // Título CATEGORÍAS
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'CATEGORÍAS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // Lista de categorías con contador de tareas pendientes
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, categoryState) {
                      if (categoryState is CategoryLoaded) {
                        final categorias = categoryState.categorias;
                        if (categorias.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(
                              'No hay categorías',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          );
                        }
                        return BlocBuilder<TaskBloc, TaskState>(
                          builder: (context, taskState) {
                            Map<int, int> tareasPorCategoria = {};
                            
                            if (taskState is TaskLoaded) {
                              final tareasPendientes = taskState.tareas.where((t) => !t.completada).toList();
                              for (final tarea in tareasPendientes) {
                                if (tarea.categoriaId != null) {
                                  tareasPorCategoria[tarea.categoriaId!] = 
                                      (tareasPorCategoria[tarea.categoriaId!] ?? 0) + 1;
                                }
                              }
                            }
                            
                            return Column(
                              children: categorias.map((categoria) {
                                final count = tareasPorCategoria[categoria.id] ?? 0;
                                return _buildCategoryItem(
                                  context: context,
                                  nombre: categoria.nombre,
                                  color: categoria.color,
                                  count: count,
                                );
                              }).toList(),
                            );
                          },
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          'Cargando categorías...',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32, thickness: 1),
                  // ✅ SECCIÓN EQUIPOS - Cierra drawer y cambia a la pestaña de equipos
                  _buildDrawerItem(
                    icon: Icons.group,
                    title: 'Equipos',
                    filterValue: 'equipos',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context); // Cerrar drawer
                      if (onEquiposTap != null) {
                        onEquiposTap!(); // Cambiar a la pestaña de equipos
                      }
                    },
                  ),
                  // ✅ SECCIÓN PERFIL - Cierra drawer y cambia a la pestaña de perfil
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'Perfil',
                    filterValue: 'perfil',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context); // Cerrar drawer
                      if (onPerfilTap != null) {
                        onPerfilTap!(); // Cambiar a la pestaña de perfil
                      }
                    },
                  ),
                  // ❌ ELIMINADO "Gestionar Categorías"
                  const SizedBox(height: 24),
                  // Botón de cerrar sesión
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutEvent());
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                      label: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String filterValue,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primaryGreen : AppColors.textMuted,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? AppColors.primaryGreen : AppColors.textDark,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: isActive
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String nombre,
    required String color,
    required int count,
  }) {
    Color categoryColor = _parseHexColor(color);
    
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: categoryColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        nombre,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: count > 0 ? categoryColor.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count > 0 ? '$count' : '0',
          style: TextStyle(
            color: count > 0 ? categoryColor : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        // TODO: Filtrar tareas por esta categoría
      },
    );
  }

  Color _parseHexColor(String hexString) {
    if (hexString.isEmpty) return AppColors.primaryGreen;
    
    try {
      final buffer = StringBuffer();
      String cleanHex = hexString.replaceFirst('#', '');
      if (cleanHex.length == 6) buffer.write('ff');
      buffer.write(cleanHex);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primaryGreen;
    }
  }
}