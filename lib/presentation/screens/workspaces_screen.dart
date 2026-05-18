import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/workspace/workspace_bloc.dart';

class WorkspacesScreen extends StatefulWidget {
  const WorkspacesScreen({super.key});

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkspaceBloc>().add(WorkspaceLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Workspaces'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<WorkspaceBloc, WorkspaceState>(
        listener: (context, state) {
          if (state is WorkspaceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkspaceLoading || state is WorkspaceInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          if (state is WorkspaceLoaded) {
            if (state.workspaces.isEmpty) {
              return const Center(
                child: Text(
                  'No tienes ningun workspace creado.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.workspaces.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final workspace = state.workspaces[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.group, color: Colors.white),
                    ),
                    title: Text(
                      workspace.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        workspace.descripcion.isNotEmpty
                            ? workspace.descripcion
                            : 'Sin descripcion',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            );
          }

          if (state is WorkspaceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WorkspaceBloc>().add(WorkspaceLoadEvent());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Estado no reconocido'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateWorkspaceDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showCreateWorkspaceDialog() async {
    final workspaceBloc = context.read<WorkspaceBloc>();

    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _CreateWorkspaceDialog(),
    );

    if (!mounted || data == null) return;
    workspaceBloc.add(WorkspaceCreateEvent(workspaceData: data));
  }
}

class _CreateWorkspaceDialog extends StatefulWidget {
  const _CreateWorkspaceDialog();

  @override
  State<_CreateWorkspaceDialog> createState() => _CreateWorkspaceDialogState();
}

class _CreateWorkspaceDialogState extends State<_CreateWorkspaceDialog> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _nombreError;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Workspace'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre del Workspace *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.edit, color: Colors.teal),
              errorText: _nombreError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descripcionController,
            decoration: const InputDecoration(
              labelText: 'Descripcion (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description, color: Colors.teal),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: const Text('Crear', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _submit() {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      setState(() {
        _nombreError = 'El nombre es obligatorio';
      });
      return;
    }

    Navigator.of(context).pop({
      'nombre': nombre,
      'descripcion': _descripcionController.text.trim(),
    });
  }
}
