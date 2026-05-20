import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../../../../logic/auth/auth_bloc.dart';
import '../../../../logic/category/category_bloc.dart';

class CustomDrawer extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const CustomDrawer({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 🚀 ENCABEZADO PREMIUM: LOGO Y SUBTÍTULO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'TaskFlow',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Text(
                        'Centro de productividad',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(color: AppColors.borderLight, height: 1),

            // 📋 MENÚS DE NAVEGACIÓN Y FILTROS PRINCIPALES
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildNavItem(
                    icon: Icons.light_mode_outlined,
                    label: 'Mi Día',
                    isSelected: activeFilter == 'Hoy',
                    onTap: () {
                      onFilterChanged('Hoy');
                      Navigator.pop(context);
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'Próximas Tareas',
                    isSelected: activeFilter == 'Próximas',
                    onTap: () {
                      onFilterChanged('Próximas');
                      Navigator.pop(context);
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Completadas',
                    isSelected: activeFilter == 'Completadas',
                    onTap: () {
                      onFilterChanged('Completadas');
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🏷️ SECCIÓN: CATEGORÍAS (Conectada a la DB real)
                  _buildSectionHeader('CATEGORÍAS', onAddPressed: () {
                    // TODO: Aquí puedes abrir tu formulario de crear categoría
                  }),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen)));
                      }
                      if (state is CategoryLoaded) {
                        return Column(
                          children: state.categorias.map((cat) {
                            // Parsea el color hex de tu base de datos o usa el verde manzana si falla
                            Color catColor;
                            try {
                              catColor = Color(int.parse(cat.color.replaceFirst('#', '0xff')));
                            } catch (_) {
                              catColor = AppColors.primaryGreen;
                            }

                            return _buildNavItem(
                              iconWidget: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                              ),
                              label: cat.nombre,
                              isSelected: activeFilter == cat.nombre,
                              trailingText: '0', // Contador de tareas de la db si decides implementarlo
                              onTap: () {
                                onFilterChanged(cat.nombre);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 16),

                  // 👥 SECCIÓN: ESPACIO DE EQUIPO (Desplegable interactivo)
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Icon(Icons.group_work_outlined, color: AppColors.textDark.withOpacity(0.8), size: 22),
                      title: const Text(
                        'Espacio de equipo',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                      iconColor: AppColors.textMuted,
                      collapsedIconColor: AppColors.textMuted,
                      childrenPadding: const EdgeInsets.only(left: 12),
                      children: [
                        _buildNavItem(
                          icon: Icons.dashboard_customize_outlined,
                          label: 'holiwi',
                          isSelected: activeFilter == 'holiwi',
                          badgeText: 'Admin',
                          onTap: () {
                            onFilterChanged('holiwi');
                            Navigator.pop(context);
                          },
                        ),
                        _buildNavItem(
                          icon: Icons.view_kanban_outlined,
                          label: 'Tablero Kanban',
                          isSelected: activeFilter == 'Kanban',
                          onTap: () {
                            onFilterChanged('Kanban');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ⚙️ SECCIÓN INFERIOR FIJA: PERFIL Y LOGOUT
            const Divider(color: AppColors.borderLight, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Configuración de Perfil',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Redirigir a pestaña de perfil o vista correspondiente
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar Sesión',
                    isSelected: false,
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      context.read<AuthBloc>().add(AuthLogoutEvent());
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE DISEÑO ---
  Widget _buildSectionHeader(String title, {required VoidCallback onAddPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.1)),
          GestureDetector(
            onTap: onAddPressed,
            child: const Icon(Icons.add, size: 16, color: AppColors.textMuted),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? trailingText,
    String? badgeText,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.activeTabBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: iconWidget ?? Icon(
          icon,
          color: isSelected ? AppColors.primaryGreen : (iconColor ?? AppColors.textDark.withOpacity(0.8)),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primaryGreen : (textColor ?? AppColors.textDark),
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryGreenPastel, borderRadius: BorderRadius.circular(8)),
                child: const Text('Admin', style: TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
              )
            : (trailingText != null ? Text(trailingText, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)) : null),
      ),
    );
  }
}