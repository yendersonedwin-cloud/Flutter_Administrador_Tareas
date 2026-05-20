import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

import '../../../core/app_colors.dart';
import '../../../data/models/workspace_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/workspace_repository.dart';
import '../../../logic/task/task_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import 'workspace_create_task_modal.dart';

class WorkspaceDashboardView extends StatefulWidget {
  final WorkspaceModel workspace;
  final VoidCallback onRegresar;
  final VoidCallback onEliminar;

  const WorkspaceDashboardView({
    super.key, 
    required this.workspace,
    required this.onRegresar,
    required this.onEliminar,
  });

  @override
  State<WorkspaceDashboardView> createState() => _WorkspaceDashboardViewState();
}

class _WorkspaceDashboardViewState extends State<WorkspaceDashboardView> {
  // Future cacheado para evitar rebuilds innecesarios
  late Future<List<Map<String, dynamic>>> _miembrosFuture;
  
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(TaskLoadEvent());
    _miembrosFuture = _cargarMiembros();
  }

  // Getters para obtener datos del usuario autenticado
  int get _currentUserId {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.userId;
    }
    return 0;
  }

  String get _currentUsername {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.username;
    }
    return '';
  }

  // Método para recargar miembros manualmente (ej: después de invitar)
  void _recargarMiembros() {
    setState(() {
      _miembrosFuture = _cargarMiembros();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: widget.onRegresar,
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryGreen, width: 1.5),
          ),
          child: Text(
            widget.workspace.nombre,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined, color: AppColors.textMuted),
            tooltip: 'Tablero Kanban',
            onPressed: () {}, 
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppColors.textMuted),
            tooltip: 'Métricas',
            onPressed: () {}, 
          ),
          if (widget.workspace.esAdmin)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: 'Eliminar Workspace',
              onPressed: () => _confirmarEliminarWorkspace(context),
            ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            List<TaskModel> tareasFiltradas = [];

            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
            }

            if (state is TaskLoaded) {
              tareasFiltradas = state.tareas.where((t) => t.workspaceId == widget.workspace.id).toList();
            }

            if (state is TaskError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }

            final int totalTareas = tareasFiltradas.length;
            final int completadas = tareasFiltradas.where((t) => t.completada || t.estado == 'DONE').length;
            final int pendientes = totalTareas - completadas;
            final double progreso = totalTareas > 0 ? (completadas / totalTareas) * 100 : 0;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskBloc>().add(TaskLoadEvent());
                _recargarMiembros(); // También recargar miembros al refrescar
              },
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildCardMetrica('$totalTareas', 'Tareas\nTotales', Icons.assignment_outlined, const Color(0xFF10B981))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCardMetrica('$completadas', 'Completadas\n${progreso.toStringAsFixed(0)}%', Icons.check_circle_outline, const Color(0xFF059669))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildCardMetrica('$pendientes', 'Pendientes', Icons.history_toggle_off_rounded, const Color(0xFFF59E0B))),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text('Miembros del Equipo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    _buildFilaMiembrosDinamica(),
                    const SizedBox(height: 28),
                    const Text('Tareas del equipo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    _buildListaTareasDinamica(tareasFiltradas),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () => _abrirFormularioCrear(context),
      ),
    );
  }

  Widget _buildListaTareasDinamica(List<TaskModel> tareas) {
    if (tareas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in_outlined, 
                size: 56, 
                color: AppColors.textMuted.withOpacity(0.4)
              ),
              const SizedBox(height: 14),
              const Text(
                'No hay tareas asignadas',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              const Text(
                'El flujo de trabajo está al día. Usa el botón inferior (+) para añadir un nuevo pendiente al sprint.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tareas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tarea = tareas[index];
        final prioridadLabel = _getPrioridadTexto(tarea.prioridad);
        
        Color colorPrioridad = Colors.green;
        if (tarea.prioridad == 'A') colorPrioridad = Colors.red;
        if (tarea.prioridad == 'M') colorPrioridad = Colors.orange;

        final stringAsignado = tarea.asignadoInfo != null 
            ? (tarea.asignadoInfo!['username'] ?? 'Sin asignar') 
            : 'Sin asignar';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 4, 
                height: 40, 
                decoration: BoxDecoration(color: colorPrioridad, borderRadius: BorderRadius.circular(10))
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.titulo, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: AppColors.textDark, 
                        fontSize: 14,
                        decoration: (tarea.completada || tarea.estado == 'DONE') ? TextDecoration.lineThrough : null
                      )
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: colorPrioridad.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(prioridadLabel, style: TextStyle(color: colorPrioridad, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Text('👤 $stringAsignado', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                onSelected: (accion) {
                  if (accion == 'editar') _abrirFormularioEditar(context, tarea);
                  if (accion == 'eliminar') _eliminarTarea(context, tarea.id);
                  if (accion == 'toggle') {
                    context.read<TaskBloc>().add(TaskToggleCompleteEvent(tarea.id!, !tarea.completada));
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle', 
                    child: Text(tarea.completada ? 'Marcar como pendiente' : 'Marcar como completada')
                  ),
                  const PopupMenuItem(value: 'editar', child: Text('Editar')),
                  const PopupMenuItem(value: 'eliminar', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilaMiembrosDinamica() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _miembrosFuture, // ✅ Usamos el future cacheado
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Cargando miembros...'),
              ],
            ),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryGreenPastel,
                  child: Text(
                    widget.workspace.nombre[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Aún no hay miembros con tareas asignadas',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          );
        }
        
        final miembros = snapshot.data!;
        
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ...miembros.take(3).map((m) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: (m['rol'] == 'Admin' || 
                              (widget.workspace.esAdmin && m['id'] == _currentUserId))
                              ? AppColors.primaryGreenPastel
                              : Colors.blue.shade50,
                          child: Text(
                            (m['username'] as String)[0].toUpperCase(),
                            style: TextStyle(
                              color: (m['rol'] == 'Admin' || 
                                  (widget.workspace.esAdmin && m['id'] == _currentUserId))
                                  ? AppColors.primaryGreen
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['username'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              m['rol'] ?? 'Miembro',
                              style: TextStyle(
                                fontSize: 11,
                                color: (m['rol'] == 'Admin' || 
                                    (widget.workspace.esAdmin && m['id'] == _currentUserId))
                                    ? AppColors.primaryGreen
                                    : Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )).toList(),
                  if (miembros.length > 3)
                    const Expanded(
                      child: Text(
                        '...',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.workspace.codigo));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📋 Código de invitación copiado')),
                      );
                      _mostrarDialogoMiembros(context, miembros);
                    },
                    icon: const Icon(Icons.people_outline, size: 16, color: AppColors.primaryGreen),
                    label: const Text(
                      'Ver todos',
                      style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _cargarMiembros() async {
    try {
      final repository = WorkspaceRepository();
      final miembros = await repository.getWorkspaceMembers(widget.workspace.id);
      
      if (widget.workspace.esAdmin && miembros.every((m) => m['id'] != _currentUserId)) {
        miembros.insert(0, {
          'id': _currentUserId,
          'username': _currentUsername.isNotEmpty ? '$_currentUsername (Tú - Admin)' : 'Tú (Admin)',
          'email': '',
          'first_name': '',
          'last_name': '',
          'rol': 'Admin',
        });
      }
      
      return miembros;
    } catch (e) {
      log('Error cargando miembros: $e');
      return [];
    }
  }

  void _mostrarDialogoMiembros(BuildContext context, List<Map<String, dynamic>> miembros) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Miembros del Equipo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${miembros.length} miembros activos',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const Divider(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: miembros.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final m = miembros[index];
                    final esAdmin = m['rol'] == 'Admin' || 
                        (widget.workspace.esAdmin && m['id'] == _currentUserId);
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: esAdmin 
                            ? AppColors.primaryGreenPastel 
                            : Colors.blue.shade50,
                        child: Text(
                          (m['username'] as String)[0].toUpperCase(),
                          style: TextStyle(
                            color: esAdmin 
                                ? AppColors.primaryGreen 
                                : Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        m['username'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(m['rol'] ?? 'Miembro'),
                      trailing: esAdmin
                          ? const Icon(Icons.star, color: Colors.amber, size: 18)
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.workspace.codigo));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado para invitar')),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Invitar más miembros'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getPrioridadTexto(String inicial) {
    switch (inicial) {
      case 'A': return 'Alta';
      case 'M': return 'Media';
      case 'B': return 'Baja';
      default: return 'Baja';
    }
  }

  void _confirmarEliminarWorkspace(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Workspace?'),
        content: const Text('Esta acción borrará permanentemente el equipo y todas sus tareas asociadas. ¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); 
              widget.onEliminar();    
            },
            child: const Text('Eliminar Todo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMetrica(String numero, String texto, IconData icono, Color colorIndicador) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: const Color(0xFFE5E7EB))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text(numero, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Icon(icono, color: colorIndicador, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(texto, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.2)),
        ],
      ),
    );
  }

  void _abrirFormularioCrear(BuildContext context) async {
    final res = await showModalBottomSheet<Map<String, dynamic>>(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => WorkspaceCreateTaskModal(workspace: widget.workspace)
    );
    if (res != null) {
      res['workspace'] = widget.workspace.id;
      context.read<TaskBloc>().add(TaskCreateEvent(tareaData: res));
      _recargarMiembros(); // Recargar miembros después de crear tarea
    }
  }

  void _abrirFormularioEditar(BuildContext context, TaskModel tarea) async {
    final Map<String, dynamic> tareaMap = {
      'titulo': tarea.titulo,
      'descripcion': tarea.descripcion,
      'prioridad': tarea.prioridad,
      'workspace': widget.workspace.id,
      'asignado_a': tarea.asignadoA,
    };

    final res = await showModalBottomSheet<Map<String, dynamic>>(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => WorkspaceCreateTaskModal(workspace: widget.workspace, tareaAEditar: tareaMap)
    );
    if (res != null) {
      context.read<TaskBloc>().add(TaskUpdateEvent(id: tarea.id!, tareaData: res));
    }
  }

  void _eliminarTarea(BuildContext context, int? id) {
    if (id != null) {
      context.read<TaskBloc>().add(TaskDeleteEvent(id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea eliminada 🗑️')));
    }
  }
}