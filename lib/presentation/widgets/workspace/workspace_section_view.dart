import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app_colors.dart';
import '../../../logic/workspace/workspace_bloc.dart';
import 'workspace_empty_view.dart';
import 'workspace_dashboard_view.dart';

class WorkspaceSectionView extends StatefulWidget {
  const WorkspaceSectionView({super.key});

  @override
  State<WorkspaceSectionView> createState() => _WorkspaceSectionViewState();
}

class _WorkspaceSectionViewState extends State<WorkspaceSectionView> {
  int? _workspaceSeleccionadoId;

  @override
  void initState() {
    super.initState();
    context.read<WorkspaceBloc>().add(WorkspaceLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final workspaceBloc = context.read<WorkspaceBloc>();

    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        if (state is WorkspaceLoading || state is WorkspaceInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (state is WorkspaceError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => workspaceBloc.add(WorkspaceLoadEvent()),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      child: const Text('Reintentar cargar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is WorkspaceLoaded) {
          if (state.workspaces.isEmpty) {
            return const WorkspaceEmptyView();
          }

          if (_workspaceSeleccionadoId != null) {
            final workspaceActivo = state.workspaces.firstWhere(
              (w) => w.id == _workspaceSeleccionadoId,
              orElse: () => state.workspaces.first,
            );
            
            return WillPopScope(
              onWillPop: () async {
                setState(() => _workspaceSeleccionadoId = null);
                return false;
              },
              child: WorkspaceDashboardView(
                workspace: workspaceActivo,
                onRegresar: () => setState(() => _workspaceSeleccionadoId = null),
                onEliminar: () {
                  workspaceBloc.add(WorkspaceDeleteEvent(id: workspaceActivo.id));

                  setState(() {
                    _workspaceSeleccionadoId = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Workspace eliminado correctamente 🗑️'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text(
                'Mis Equipos',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Scaffold(body: WorkspaceEmptyView()),
                      ),
                    ).then((_) => workspaceBloc.add(WorkspaceLoadEvent()));
                  },
                  icon: const Icon(Icons.add, color: AppColors.primaryGreen, size: 18),
                  label: const Text(
                    'Gestionar',
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: state.workspaces.length,
              itemBuilder: (context, index) {
                final ws = state.workspaces[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: ws.esAdmin ? AppColors.primaryGreenPastel : Colors.blue.shade50,
                      child: Icon(
                        ws.esAdmin ? Icons.king_bed_outlined : Icons.supervised_user_circle_outlined,
                        color: ws.esAdmin ? AppColors.primaryGreen : Colors.blue.shade700,
                      ),
                    ),
                    title: Text(
                      ws.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        ws.esAdmin ? '👑 Eres Administrador' : '👥 Eres Miembro',
                        style: TextStyle(
                          color: ws.esAdmin ? AppColors.primaryGreen : Colors.blue.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                    onTap: () {
                      setState(() => _workspaceSeleccionadoId = ws.id);
                    },
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}