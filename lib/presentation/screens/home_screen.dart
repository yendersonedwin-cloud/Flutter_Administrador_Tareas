import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/task/task_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/workspace/workspace_bloc.dart'; // Importamos el nuevo BLoC
import '../../data/models/task_model.dart';
import 'add_edit_task_screen.dart';
import 'categories_screen.dart';
import 'workspaces_screen.dart'; // Importamos la pantalla de workspaces
import 'profile_screen.dart'; // 👈 Importamos la pantalla de perfil

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controlamos qué vista o pestaña está activa en la plantilla funcional
  int _currentSectionIndex = 0; 

  @override
  void initState() {
    super.initState();
    // Inicializamos la carga de datos core de la app
    context.read<TaskBloc>().add(TaskLoadEvent());
    context.read<WorkspaceBloc>().add(WorkspaceLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Definimos las pantallas que se renderizan según la sección seleccionada
    final List<Widget> _screens = [
      _buildMyDayTemplate(),       // Índice 0: Vista de Tareas / Mi Día
      const WorkspacesScreen(),    // Índice 1: Vista de Workspaces
      const ProfileScreen(),       // 👈 Índice 2: Vista de Perfil
    ];

    final List<String> _titles = [
      'Mi Día',
      'Mis Workspaces',
      'Configuración de Perfil', // 👈 Título para el Perfil
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentSectionIndex]),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Botón de Categorías - Sigue operativo
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Categorías',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoriesScreen(),
                ),
              );
              if (!context.mounted) return;
              context.read<TaskBloc>().add(TaskLoadEvent());
            },
          ),
          // Botón de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutEvent());
            },
          ),
        ],
      ),
      // Muestra la pantalla activa según el índice seleccionado en el menú móvil
      body: _screens[_currentSectionIndex],
      
      // Barra de navegación inferior (Plantilla temporal para alternar pantallas)
      // Esto simula la selección del menú lateral de tu imagen de forma rápida y funcional
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentSectionIndex > 2 ? 0 : _currentSectionIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Asegura que se muestren correctamente los 3 ítems
        onTap: (index) {
          setState(() {
            _currentSectionIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined),
            activeIcon: Icon(Icons.wb_sunny),
            label: 'Mi Día',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work_outlined),
            activeIcon: Icon(Icons.group_work),
            label: 'Workspaces',
          ),
          BottomNavigationBarItem(
            // 👈 Ítem de Perfil agregado
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      
      // El botón flotante cambia de comportamiento según la pantalla activa
      floatingActionButton: _currentSectionIndex == 0 
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditTaskScreen(),
                  ),
                );
                if (!context.mounted) return;
                context.read<TaskBloc>().add(TaskLoadEvent());
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null, // En la pantalla de Workspaces y Perfil, no se muestra este FAB
    );
  }

  // CÓDIGO ORIGINAL DE TU LISTA DE TAREAS EXTRAÍDO COMPLETAMENTE PARA NO DAÑAR TU AVANCE
  Widget _buildMyDayTemplate() {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TaskLoaded) {
          if (state.tareas.isEmpty) {
            return const Center(child: Text('No hay tareas para hoy.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.tareas.length,
            itemBuilder: (context, index) {
              final tarea = state.tareas[index];
              return _buildTaskCard(tarea);
            },
          );
        }

        return const Center(child: Text('Inicializando tareas...'));
      },
    );
  }

  Widget _buildTaskCard(TaskModel tarea) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shadowColor: Colors.black12,
      child: ListTile(
        leading: Checkbox(
          value: tarea.completada,
          onChanged: (bool? value) {
            if (value != null && tarea.id != null) {
              context.read<TaskBloc>().add(
                TaskToggleCompleteEvent(tarea.id!, value),
              );
            }
          },
        ),
        title: Text(
          tarea.titulo,
          style: TextStyle(
            decoration: tarea.completada ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(tarea.descripcion),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTaskScreen(task: tarea),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red,
              onPressed: () => _showDeleteDialog(context, tarea.id!),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(TaskDeleteEvent(taskId));
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}