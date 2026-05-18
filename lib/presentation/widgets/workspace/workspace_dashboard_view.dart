import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/workspace_model.dart';
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
  final List<Map<String, dynamic>> _tareasDeEquipo = [];

  @override
  Widget build(BuildContext context) {
    final int totalTareas = _tareasDeEquipo.length;
    final int completadas = _tareasDeEquipo.where((t) => t['completada'] == true).length;
    final int pendientes = totalTareas - completadas;
    final double progreso = totalTareas > 0 ? (completadas / totalTareas) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: widget.onRegresar,
        ),
        // ✨ DISEÑO DE TÍTULO RESALTADO Y PROFESIONAL
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
          // 📊 BOTONES RESTAURADOS
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined, color: AppColors.textMuted),
            tooltip: 'Tablero Kanban',
            onPressed: () {}, // Próximamente screen
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppColors.textMuted),
            tooltip: 'Métricas',
            onPressed: () {}, // Próximamente screen
          ),
          // 🗑️ ELIMINAR WORKSPACE (Solo Admin)
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
              _buildListaTareasDinamica(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () => _abrirFormularioCrear(context),
      ),
    );
  }

  // 📝 LISTA DE TAREAS MEJORADA CON PRIORIDAD VISIBLE
  Widget _buildListaTareasDinamica() {
  // ✨ Si no hay pendientes, mostramos un estado vacío elegante y corporativo
  if (_tareasDeEquipo.isEmpty) {
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
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.bold, 
                color: AppColors.textDark
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'El flujo de trabajo está al día. Usa el botón inferior (+) para añadir un nuevo pendiente al sprint.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12, 
                color: AppColors.textMuted,
                height: 1.4
              ),
            ),
          ],
        ),
      ),
    );
  }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tareasDeEquipo.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tarea = _tareasDeEquipo[index];
        final prioridad = tarea['prioridad'] ?? 'Baja';
        
        // Color según prioridad
        Color colorPrioridad = Colors.green;
        if (prioridad == 'Alta') colorPrioridad = Colors.red;
        if (prioridad == 'Media') colorPrioridad = Colors.orange;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(width: 4, height: 40, decoration: BoxDecoration(color: colorPrioridad, borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tarea['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // ✨ BADGE DE PRIORIDAD
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: colorPrioridad.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(prioridad, style: TextStyle(color: colorPrioridad, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Text('👤 ${tarea['asignado_a']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                onSelected: (accion) {
                  if (accion == 'editar') _abrirFormularioEditar(context, tarea, index);
                  if (accion == 'eliminar') _eliminarTarea(index);
                },
                itemBuilder: (context) => [
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

  // ⚠️ ALERTA DE SEGURIDAD PARA ELIMINAR EL WORKSPACE
 void _confirmarEliminarWorkspace(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Workspace?'),
        content: const Text('Esta acción borrará permanentemente el equipo y todas sus tareas asociadas en Django. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancelar')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              widget.onEliminar();    // ✨ ¡Aquí eliminamos el workspace del estado real!
            },
            child: const Text('Eliminar Todo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS DE APOYO (Pertenecen a la lógica anterior) ---
  Widget _buildCardMetrica(String numero, String texto, IconData icono, Color colorIndicador) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(numero, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          Icon(icono, color: colorIndicador, size: 20),
        ]),
        const SizedBox(height: 8),
        Text(texto, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.2)),
      ]),
    );
  }

  Widget _buildFilaMiembrosDinamica() {
    final List<Map<String, String>> miembrosVisibles = [{'nombre': 'Sebas', 'rol': 'Admin'}];
    if (widget.workspace.cantidadMiembros > 1) miembrosVisibles.add({'nombre': 'Lizeth', 'rol': 'Miembro'});
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        ...miembrosVisibles.map((m) => Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: m['rol'] == 'Admin' ? Colors.orange.withOpacity(0.2) : Colors.purple.withOpacity(0.2), child: Text(m['nombre']![0], style: TextStyle(color: m['rol'] == 'Admin' ? Colors.orange : Colors.purple, fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(width: 6),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m['nombre']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)), Text(m['rol']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))])
          ]),
        )).toList(),
        const Spacer(),
        TextButton.icon(onPressed: () { Clipboard.setData(ClipboardData(text: widget.workspace.codigo)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📋 Código copiado'))); }, icon: const Icon(Icons.add, size: 16, color: AppColors.primaryGreen), label: const Text('Invitar', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)))
      ]),
    );
  }

  void _abrirFormularioCrear(BuildContext context) async {
    final res = await showModalBottomSheet<Map<String, dynamic>>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => WorkspaceCreateTaskModal(workspace: widget.workspace));
    if (res != null) setState(() { _tareasDeEquipo.add({'id': _tareasDeEquipo.length + 1, ...res, 'completada': false}); });
  }

  void _abrirFormularioEditar(BuildContext context, Map<String, dynamic> tarea, int index) async {
    final res = await showModalBottomSheet<Map<String, dynamic>>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => WorkspaceCreateTaskModal(workspace: widget.workspace, tareaAEditar: tarea));
    if (res != null) setState(() { _tareasDeEquipo[index] = {'id': tarea['id'], ...res, 'completada': tarea['completada']}; });
  }

  void _eliminarTarea(int index) { setState(() { _tareasDeEquipo.removeAt(index); }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea eliminada 🗑️'))); }
}