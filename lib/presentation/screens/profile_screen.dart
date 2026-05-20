import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/task/task_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        // ✅ CORREGIDO: quitado el leading con Navigator.pop — cuando esta pantalla
        // vive dentro del IndexedStack del HomeScreen no tiene a dónde hacer pop
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String username = '';
          String email = '';

          if (authState is AuthAuthenticated) {
            username = authState.username.isNotEmpty ? authState.username : 'Usuario';
            email = '${username.toLowerCase()}@taskflow.com';
          }

          return BlocBuilder<TaskBloc, TaskState>(
            builder: (context, taskState) {
              int totalTareas = 0;
              int tareasCompletadas = 0;
              int tareasPendientes = 0;
              double progreso = 0;

              if (taskState is TaskLoaded) {
                totalTareas = taskState.tareas.length;
                tareasCompletadas = taskState.tareas.where((t) => t.completada).length;
                tareasPendientes = totalTareas - tareasCompletadas;
                progreso = totalTareas > 0 ? (tareasCompletadas / totalTareas) : 0;
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header con avatar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFE8F0FE),
                              child: Text(
                                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 74, 226, 74),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Tarjeta de estadísticas
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color.fromARGB(255, 75, 201, 25), Color(0xFF357ABD)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 89, 212, 72).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('$totalTareas', 'Total', Colors.white),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                _buildStatItem('$tareasCompletadas', 'Completadas', Colors.white),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                _buildStatItem('$tareasPendientes', 'Pendientes', Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sección de progreso
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progreso General',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                'Meta mensual',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progreso,
                              backgroundColor: const Color(0xFFE8E8E8),
                              color: const Color.fromARGB(255, 74, 226, 74),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progreso * 100).toInt()}% completado',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(255, 99, 226, 74),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Menú de opciones
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Configuración',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Información personal',
                            subtitle: 'Nombre, email, teléfono',
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 60),
                          _buildMenuItem(
                            icon: Icons.lock_outline,
                            title: 'Seguridad',
                            subtitle: 'Contraseña, autenticación',
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 60),
                          _buildMenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notificaciones',
                            subtitle: 'Alertas, recordatorios',
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 60),
                          _buildMenuItem(
                            icon: Icons.palette_outlined,
                            title: 'Apariencia',
                            subtitle: 'Tema oscuro/claro',
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 60),
                          _buildMenuItem(
                            icon: Icons.language_outlined,
                            title: 'Idioma',
                            subtitle: 'Español / English',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botón cerrar sesión
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: Color(0xFFFF5A5A), size: 20),
                        label: const Text(
                          'Cerrar sesión',
                          style: TextStyle(color: Color(0xFFFF5A5A), fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF5A5A), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color.fromARGB(255, 99, 226, 74), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFFC7C7CC)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutEvent());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A5A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}