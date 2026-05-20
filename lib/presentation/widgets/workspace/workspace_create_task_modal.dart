import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/workspace_model.dart';

class WorkspaceCreateTaskModal extends StatefulWidget {
  final WorkspaceModel workspace;
  final Map<String, dynamic>? tareaAEditar;

  const WorkspaceCreateTaskModal({
    super.key, 
    required this.workspace, 
    this.tareaAEditar,
  });

  @override
  State<WorkspaceCreateTaskModal> createState() => _WorkspaceCreateTaskModalState();
}

class _WorkspaceCreateTaskModalState extends State<WorkspaceCreateTaskModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  String _prioridad = 'Media'; // 'Baja', 'Media', 'Alta'
  String? _usuarioAsignado;
  DateTime _fechaEntrega = DateTime.now();
  bool _esEdicion = false;

  // 🚀 Función interna para traducir la prioridad al formato que exige Django ('A', 'M', 'B')
  String _mapearPrioridad(String textoPrioridad) {
    switch (textoPrioridad) {
      case 'Alta':
        return 'A';
      case 'Baja':
        return 'B';
      case 'Media':
      default:
        return 'M';
    }
  }

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.tareaAEditar != null;
    _titleController = TextEditingController(text: _esEdicion ? widget.tareaAEditar!['titulo'] : '');
    _descController = TextEditingController(text: _esEdicion ? widget.tareaAEditar!['descripcion'] : '');
    
    if (_esEdicion) {
      _prioridad = widget.tareaAEditar!['prioridad'] ?? 'Media';
      _usuarioAsignado = widget.tareaAEditar!['asignado_a'];
      if (widget.tareaAEditar!['fecha_vencimiento'] != null) {
        try {
          _fechaEntrega = DateTime.parse(widget.tareaAEditar!['fecha_vencimiento']);
        } catch (_) {
          _fechaEntrega = DateTime.now();
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> listaAsignables = ['Sebas (Tú)'];
    if (widget.workspace.cantidadMiembros > 1) {
      listaAsignables.add('Lizeth');
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300, 
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  _esEdicion ? '📝 Modificar Tarea' : '🚀 Nueva Tarea de Equipo',
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.textDark,
                    letterSpacing: -0.5
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _esEdicion ? 'Edita los campos clave de este pendiente' : 'Asigna responsabilidades y organiza los sprints.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Título de la tarea',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primaryGreen, size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Por favor escribe un título' : null,
                ),
                const SizedBox(height: 18),

                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Instrucciones o notas adicionales',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Icon(Icons.description_outlined, color: AppColors.textMuted, size: 20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: listaAsignables.contains(_usuarioAsignado) ? _usuarioAsignado : null,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Asignar a un colaborador',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    ),
                  ),
                  items: listaAsignables.map((miembro) {
                    return DropdownMenuItem(value: miembro, child: Text(miembro));
                  }).toList(),
                  onChanged: (val) => setState(() => _usuarioAsignado = val),
                  validator: (value) => value == null ? 'Asigna un responsable' : null,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Nivel de Prioridad',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ['Baja', 'Media', 'Alta'].map((prio) {
                    final bool estaSeleccionado = _prioridad == prio;
                    Color colorBase = Colors.green;
                    if (prio == 'Media') colorBase = Colors.orange;
                    if (prio == 'Alta') colorBase = Colors.red;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _prioridad = prio),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: estaSeleccionado ? colorBase : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: estaSeleccionado ? colorBase : const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              prio,
                              style: TextStyle(
                                color: estaSeleccionado ? Colors.white : AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Fecha de Entrega',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _fechaEntrega,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _fechaEntrega = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.primaryGreen),
                            const SizedBox(width: 12),
                            Text(
                              '${_fechaEntrega.day}/${_fechaEntrega.month}/${_fechaEntrega.year}',
                              style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 🚀 Armamos el mapa mapeado exactamente como lo mapea TareaSerializer
                        final datosFinales = {
                          'titulo': _titleController.text.trim(),
                          'descripcion': _descController.text.trim(),
                          'prioridad': _mapearPrioridad(_prioridad), // 'A', 'M' o 'B'
                          'estado': 'TODO',
                          'completada': false,
                          'en_progreso': false,
                          'fecha_vencimiento': '${_fechaEntrega.year}-${_fechaEntrega.month.toString().padLeft(2, '0')}-${_fechaEntrega.day.toString().padLeft(2, '0')}', // Formato YYYY-MM-DD para Django
                          'workspace': widget.workspace.id,
                        };
                        Navigator.pop(context, datosFinales);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _esEdicion ? 'Guardar Cambios' : 'Crear Tarea de Equipo', 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}