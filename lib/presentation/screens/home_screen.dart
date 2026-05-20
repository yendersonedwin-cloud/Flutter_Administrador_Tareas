import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/task/task_bloc.dart';
import '../../logic/category/category_bloc.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../logic/profile/profile_state.dart';

import '../widgets/homes/productivity_card.dart';
import '../widgets/task/task_filter_tabs.dart';
import '../widgets/task/task_list_view.dart';
import '../widgets/task/add_task_modal.dart';
import '../widgets/category/category_section_view.dart'; 
import '../widgets/workspace/workspace_section_view.dart'; 
import '../widgets/navigation/custom_drawer.dart'; // 🍏 Importación del Drawer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSectionIndex = 0;
  String _activeTaskFilter = 'Todas'; // Almacena estados: 'Todas', 'Hoy', 'Próximas', 'Completadas' o nombres de categorías

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(TaskLoadEvent());
    context.read<CategoryBloc>().add(CategoryLoadEvent());
    context.read<ProfileBloc>().add(ProfileLoadEvent()); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      // 🍏 PASO CLAVE: Conectamos tu menú lateral de la foto al Scaffold
      drawer: CustomDrawer(
        activeFilter: _activeTaskFilter,
        onFilterChanged: (nuevoFiltro) {
          setState(() {
            _activeTaskFilter = nuevoFiltro;
            _currentSectionIndex = 0; // Fuerza a regresar al dashboard principal para ver las tareas filtradas
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        // 🍏 Botón personalizado de menú para abrir el Drawer con las 3 líneas
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textDark, size: 26),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreenPastel,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business_center_rounded, 
                color: AppColors.primaryGreen, 
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'TaskFlow',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentSectionIndex,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildMainDashboardView(),
            ),
          ),
          const WorkspaceSectionView(), 
          _buildProfileSectionView(),   
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surfaceWhite,
        currentIndex: _currentSectionIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        enableFeedback: false, 
        onTap: (index) => setState(() => _currentSectionIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'Equipos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskModal(),
          );
          if (!context.mounted) return;
          if (created == true) {
            context.read<TaskBloc>().add(TaskLoadEvent());
          }
        },
        backgroundColor: AppColors.primaryGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildMainDashboardView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              String username = 'Usuario';
              if (state is ProfileLoaded) username = state.perfil.usuario.username;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, $username 👋', style: const TextStyle(color: AppColors.textDark, fontSize: 26, fontWeight: FontWeight.bold)),
                  const Text('Lunes, 18 de Mayo', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const ProductivityCard(), 
          const SizedBox(height: 24),
          // Las pestañas rápidas del dashboard
          TaskFilterTabs( 
            activeFilter: _activeTaskFilter,
            onFilterChanged: (nuevoFiltro) => setState(() => _activeTaskFilter = nuevoFiltro),
          ),
          const SizedBox(height: 16),
          // El listview ahora procesará los filtros nuevos ('Completadas', etc.)
          TaskListView(activeFilter: _activeTaskFilter), 
          const SizedBox(height: 24),
          const CategorySectionView(), 
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProfileSectionView() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        String username = 'Usuario'; String email = 'correo@taskflow.com'; String bio = 'Sin biografía añadida';
        if (profileState is ProfileLoaded) {
          username = profileState.perfil.usuario.username;
          email = profileState.perfil.usuario.email;
          bio = profileState.perfil.bio;
        }
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(radius: 54, backgroundColor: AppColors.primaryGreenPastel, child: Icon(Icons.person, size: 54, color: AppColors.primaryGreen)),
                    CircleAvatar(radius: 16, backgroundColor: AppColors.primaryGreen, child: IconButton(icon: const Icon(Icons.edit, size: 14, color: Colors.white), onPressed: () {}))
                  ],
                ),
                const SizedBox(height: 16),
                Text(username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text(email, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Text(bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                const SizedBox(height: 28),
                BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, taskState) {
                    int totales = 0; int completadas = 0; int rendimiento = 0;
                    if (taskState is TaskLoaded) {
                      totales = taskState.tareas.length;
                      completadas = taskState.tareas.where((t) => t.completada).length;
                      rendimiento = totales > 0 ? ((completadas / totales) * 100).round() : 0;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [Text(totales.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)), const Text('Tareas', style: TextStyle(fontSize: 12, color: AppColors.textMuted))]),
                          Column(children: [Text(completadas.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)), const Text('Hechas', style: TextStyle(fontSize: 12, color: AppColors.textMuted))]),
                          Column(children: [Text('$rendimiento%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)), const Text('Rendimiento', style: TextStyle(fontSize: 12, color: AppColors.textMuted))]),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(color: AppColors.surfaceWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
                  child: Column(
                    children: [
                      _buildProfileOptionTile(Icons.person_outline, 'Información personal'),
                      _buildProfileOptionTile(Icons.shield_outlined, 'Seguridad'),
                      _buildProfileOptionTile(Icons.notifications_none_outlined, 'Notificaciones'),
                      _buildProfileOptionTile(Icons.tune_outlined, 'Preferencias'),
                      _buildProfileOptionTile(Icons.language_outlined, 'Idioma', trailingText: 'Español'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(AuthLogoutEvent()),
                    icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                    label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOptionTile(IconData icon, String title, {String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDark, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
