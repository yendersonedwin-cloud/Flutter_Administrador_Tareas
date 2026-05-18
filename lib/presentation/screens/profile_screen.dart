import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../logic/profile/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Disparamos la carga del perfil al renderizar la pantalla
    context.read<ProfileBloc>().add(ProfileLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Perfil'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          }

          if (state is ProfileLoaded) {
            final perfil = state.perfil;
            final usuario = perfil.usuario;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Avatar e información básica del usuario
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal.shade100,
                        child: Text(
                          usuario.username.substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        usuario.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        usuario.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                
                // Detalles del Perfil (Información extendida de Django)
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Nombre completo'),
                  subtitle: Text(
                    '${usuario.firstName ?? ''} ${usuario.lastName ?? ''}'.trim().isNotEmpty
                        ? '${usuario.firstName} ${usuario.lastName}'
                        : 'No configurado',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('Biografía (Bio)'),
                  subtitle: Text(
                    perfil.bio.isNotEmpty ? perfil.bio : 'Sin biografía.',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditBioDialog(context, perfil.bio),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('No se pudo inicializar el perfil.'));
        },
      ),
    );
  }

  void _showEditBioDialog(BuildContext context, String currentBio) {
    final profileBloc = context.read<ProfileBloc>();
    final bioController = TextEditingController(text: currentBio);
    final rootNavigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar Biografía'),
          content: TextField(
            controller: bioController,
            decoration: const InputDecoration(
              labelText: 'Cuéntanos sobre ti',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final data = {'bio': bioController.text.trim()};
                
                // Cerramos el diálogo usando la referencia segura que aprendimos
                rootNavigator.pop();
                
                // Enviamos el PUT a Django
                profileBloc.add(ProfileUpdateEvent(data));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).whenComplete(bioController.dispose);
  }
}