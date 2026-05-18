import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../../logic/workspace/workspace_bloc.dart';


class WorkspaceEmptyView extends StatefulWidget {
  const WorkspaceEmptyView({super.key});

  @override
  State<WorkspaceEmptyView> createState() => _WorkspaceEmptyViewState();
}

class _WorkspaceEmptyViewState extends State<WorkspaceEmptyView> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Ilustración icónica superior de grupo
            const CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primaryGreenPastel,
              child: Icon(Icons.group_add_outlined, size: 44, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 16),
            const Text(
              'Trabajo en Equipo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Colabora en tiempo real con tus compañeros de clase o de proyectos de software.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),

            // 🔥 SECCIÓN A: UNIRSE CON CÓDIGO (Para Miembros)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.vpn_key_outlined, color: AppColors.primaryGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '¿Tienes un código de equipo?',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    style: const TextStyle(color: AppColors.textDark),
                    textCapitalization: TextCapitalization.characters, // Fuerza mayúsculas para códigos
                    decoration: const InputDecoration(
                      labelText: 'Código de invitación',
                      hintText: 'Ej: WS-893A',
                      labelStyle: TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        final codigo = _codeController.text.trim();
                        if (codigo.isNotEmpty) {
                          // Dispara el evento en tu Bloc conectado a Django
                          context.read<WorkspaceBloc>().add(WorkspaceJoinEvent(codigo: codigo));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Unirse al Workspace',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Separador visual elegante
            const Row(
              children: [
                Expanded(child: Divider(color: AppColors.borderLight)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('o también', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
                Expanded(child: Divider(color: AppColors.borderLight)),
              ],
            ),

            const SizedBox(height: 24),

            // 👑 SECCIÓN B: CREAR UN NUEVO WORKSPACE (Para Administradores)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.create_new_folder_outlined, color: AppColors.textMuted, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Crear un nuevo espacio',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: const InputDecoration(
                      labelText: 'Nombre del equipo o proyecto',
                      hintText: 'Ej: Proyecto Ingeniería Web',
                      labelStyle: TextStyle(color: AppColors.textMuted),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        final nombre = _nameController.text.trim();
                        if (nombre.isNotEmpty) {
                          final data = {'nombre': nombre};
                        // 🔥 PASAMOS EL PARÁMETRO NOMBRADO CORRECTAMENTE AQUÍ:
                        context.read<WorkspaceBloc>().add(WorkspaceCreateEvent(workspaceData: data));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Crear como Administrador',
                        style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}