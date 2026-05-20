import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../../logic/task/task_bloc.dart';
import '../../../logic/category/category_bloc.dart';

class AddTaskModal extends StatefulWidget {
  const AddTaskModal({super.key});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _prioridad = 'Media';
  DateTime? _fechaVencimiento;
  int? _categoriaId;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _mapPrioridad(String p) {
    switch (p) {
      case 'Alta': return 'A';
      case 'Baja': return 'B';
      default: return 'M';
    }
  }

  void _guardar() {
    if (_titleController.text.trim().isEmpty) return;

    final data = {
      'titulo': _titleController.text.trim(),
      'descripcion': _descController.text.trim(),
      'prioridad': _mapPrioridad(_prioridad),
      'estado': 'TODO',
      'completada': false,
      'en_progreso': false,
      if (_fechaVencimiento != null)
        'fecha_vencimiento': _fechaVencimiento!.toIso8601String().split('T')[0],
      if (_categoriaId != null) 'categoria': _categoriaId,
    };

    context.read<TaskBloc>().add(TaskCreateEvent(tareaData: data));
    Navigator.pop(context, true); // true = se creó algo
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20, right: 20, top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: const [
                Icon(Icons.circle, color: AppColors.primaryGreen, size: 12),
                SizedBox(width: 8),
                Text("Nueva tarea", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(color: AppColors.borderLight),

          // Título
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "¿Qué hay que hacer?",
              hintStyle: TextStyle(color: AppColors.primaryGreen),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGreen)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 16),

          // Descripción
          const Text("DESCRIPCIÓN", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              hintText: "Añade detalles opcionales...",
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
          const SizedBox(height: 16),

          // Prioridad
          const Text("PRIORIDAD", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Row(
            children: ['Alta', 'Media', 'Baja'].map((p) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p),
                selected: _prioridad == p,
                selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                onSelected: (_) => setState(() => _prioridad = p),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Fecha y Categoría
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _fechaVencimiento = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        _fechaVencimiento == null
                            ? "Fecha"
                            : "${_fechaVencimiento!.day}/${_fechaVencimiento!.month}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Categoría
              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    final cats = state is CategoryLoaded ? state.categorias : [];
                    return DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: DropdownButton<int>(
                          value: _categoriaId,
                          hint: const Text("Sin cat.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          isExpanded: true,
                          items: cats.map((cat) => DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.nombre, style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (val) => setState(() => _categoriaId = val),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Botón Crear
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _guardar,
              child: const Text("✓ Crear tarea", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}