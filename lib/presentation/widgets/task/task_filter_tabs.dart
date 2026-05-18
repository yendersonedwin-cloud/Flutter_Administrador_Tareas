import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class TaskFilterTabs extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const TaskFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Mis tareas',
          style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: ['Todas', 'Hoy', 'Próximas'].map((filter) {
            final isSelected = activeFilter == filter;
            return GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}