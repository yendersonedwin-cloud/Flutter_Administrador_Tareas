import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../logic/task/task_bloc.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  @override
  void initState() {
    super.initState();
    // Aseguramos que las tareas estén cargadas al entrar
    context.read<TaskBloc>().add(TaskLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tareas Completadas',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (state is TaskLoaded) {
            // Filtramos ÚNICAMENTE las completadas del usuario
            final completedTasks = state.tareas.where((t) => t.completada).toList();

            if (completedTasks.isEmpty) {
              return const Center(
                child: Text('No tienes tareas completadas 🎉', style: TextStyle(color: AppColors.textMuted)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: completedTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tarea = completedTasks[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.primaryGreen.withOpacity(0.5), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tarea.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, decoration: TextDecoration.lineThrough)),
                            if (tarea.descripcion.isNotEmpty)
                              Text(tarea.descripcion, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                      ),
                      const Icon(Icons.history, color: AppColors.textMuted, size: 16)
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
