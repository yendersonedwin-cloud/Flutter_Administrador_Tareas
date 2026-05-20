import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';  // ✅ CORREGIDO
import 'package:intl/intl.dart';

import '../../core/app_colors.dart';
import '../../logic/auth/auth_bloc.dart';        // ✅ CORREGIDO
import '../../logic/task/task_bloc.dart';        // ✅ CORREGIDO
import '../../logic/category/category_bloc.dart'; // ✅ CORREGIDO
import '../../logic/profile/profile_bloc.dart';   // ✅ CORREGIDO
import '../../logic/profile/profile_event.dart';
import '../../logic/profile/profile_state.dart';

import '../widgets/homes/productivity_card.dart';
import '../widgets/task/task_filter_tabs.dart';
import '../widgets/task/task_list_view.dart';
import '../widgets/task/add_task_modal.dart';    // ✅ CORREGIDO (modal no moda1)
import '../widgets/category/category_section_view.dart';
import '../widgets/workspace/workspace_section_view.dart';
import '../widgets/navigation/custom_drawer.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSectionIndex = 0;
  String _activeTaskFilter = 'Todas';

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
      drawer: CustomDrawer(
        activeFilter: _activeTaskFilter,
        onFilterChanged: (nuevoFiltro) {
          setState(() {
            _activeTaskFilter = nuevoFiltro;
            _currentSectionIndex = 0;
          });
        },
        onEquiposTap: () {
          setState(() {
            _currentSectionIndex = 1;
          });
        },
        onPerfilTap: () {
          setState(() {
            _currentSectionIndex = 2;
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.textDark,
              size: 26,
            ),
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
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textDark,
              size: 24,
            ),
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
         const ProfileScreen(),  // ✅ Correcto
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Equipos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      // ✅ FLOATING ACTION BUTTON - Solo aparece en la pestaña de Inicio (index 0)
      floatingActionButton: _currentSectionIndex == 0
          ? FloatingActionButton(
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
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // ✅ Cambia esto
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
              if (state is ProfileLoaded) {
                username = state.perfil.usuario.username;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $username 👋',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat(
                      "EEEE, d 'de' MMMM",
                      'es',
                    ).format(DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const ProductivityCard(),
          const SizedBox(height: 24),
          TaskFilterTabs(
            activeFilter: _activeTaskFilter,
            onFilterChanged: (nuevoFiltro) =>
                setState(() => _activeTaskFilter = nuevoFiltro),
          ),
          const SizedBox(height: 16),
          TaskListView(activeFilter: _activeTaskFilter),
          const SizedBox(height: 24),
          const CategorySectionView(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
