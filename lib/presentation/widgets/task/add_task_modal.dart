import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class AddTaskModal extends StatefulWidget {
  const AddTaskModal({super.key});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  String _prioridad = 'Media';

  @override
  Widget build(BuildContext context) {
    return Container(
      // Se ajusta al teclado automáticamente
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20, right: 20, top: 20
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Punto verde + Título + X
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.circle, color: AppColors.primaryGreen, size: 12),
                  SizedBox(width: 8),
                  Text("Nueva tarea", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(color: AppColors.borderLight),
          
          // TÍTULO
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "¿Qué hay que hacer?",
              hintStyle: TextStyle(color: AppColors.primaryGreen),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGreen)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 20),

          // DESCRIPCIÓN
          const Text("DESCRIPCIÓN", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              hintText: "Añade detalles opcionales...",
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
          const SizedBox(height: 20),

          // PRIORIDAD
          const Text("PRIORIDAD", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Row(
            children: ['Alta', 'Media', 'Baja'].map((p) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p),
                selected: _prioridad == p,
                onSelected: (s) => setState(() => _prioridad = p),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),

          // VENCIMIENTO Y CATEGORÍA (Fila 2 columnas)
          Row(
            children: [
              Expanded(child: _buildInputBox(Icons.calendar_today_outlined, "Fecha")),
              const SizedBox(width: 12),
              Expanded(child: _buildDropdownInput(Icons.category_outlined, "Sin cat.")),
            ],
          ),
          const SizedBox(height: 25),

          // BOTÓN CREAR
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("✓ Crear tarea", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox(IconData icon, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(hint, style: const TextStyle(color: Colors.grey))]),
    );
  }

  Widget _buildDropdownInput(IconData icon, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(hint, style: const TextStyle(color: Colors.grey))]),
        const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
      ]),
    );
  }
}