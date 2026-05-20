// lib/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();  // ✅ Con _
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // ✅ Corregido: String? en lugar de string:
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _usernameError = _usernameController.text.trim().isEmpty 
          ? 'Ingrese su usuario' 
          : null;
      _emailError = null;
      _passwordError = _passwordController.text.isEmpty 
          ? 'Ingrese su contraseña' 
          : null;
      _confirmPasswordError = _confirmPasswordController.text != _passwordController.text
          ? 'Las contraseñas no coinciden'
          : null;
    });

    if (_usernameError == null && _passwordError == null && _confirmPasswordError == null) {
      context.read<AuthBloc>().add(
        AuthRegisterEvent(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          password2: _confirmPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF22C55E),
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context); // Regresa al login
        } else if (state is AuthRegisterError) {
          String errorMsg = state.message;
          if (state.errors != null) {
            if (state.errors!.containsKey('username')) {
              errorMsg = 'Usuario: ${state.errors!['username']?.join(', ')}';
            } else if (state.errors!.containsKey('email')) {
              errorMsg = 'Email: ${state.errors!['email']?.join(', ')}';
            } else if (state.errors!.containsKey('password')) {
              errorMsg = 'Contraseña: ${state.errors!['password']?.join(', ')}';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: const [
                    Color(0xFFF0FDF4),
                    Color(0xFFDCFCE7),
                    Color(0xFFBBF7D0),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 0,
                          vertical: 20,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: isMobile ? double.infinity : 450,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF22C55E), Color(0xFF059669)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.checklist_rounded,
                                    size: 34,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Crea tu cuenta',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Empieza a gestionar tus tareas hoy',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4B5563),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                // Tarjeta
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Nombre de usuario
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Nombre de usuario',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _usernameController,
                                            onChanged: (_) {
                                              if (_usernameError != null) {
                                                setState(() {
                                                  _usernameError = null;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Elige un usuario',
                                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                                              filled: true,
                                              fillColor: const Color(0xFFF9FAFB),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          SizedBox(
                                            height: 18,
                                            child: _usernameError != null
                                                ? Text(
                                                    _usernameError!,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                      // Correo electrónico
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Correo electrónico',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              hintText: 'tu@correo.com (opcional)',
                                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                                              filled: true,
                                              fillColor: const Color(0xFFF9FAFB),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const SizedBox(height: 18),
                                        ],
                                      ),
                                      // Contraseña
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Contraseña',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            onChanged: (_) {
                                              if (_passwordError != null) {
                                                setState(() {
                                                  _passwordError = null;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Crea una contraseña',
                                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                                              filled: true,
                                              fillColor: const Color(0xFFF9FAFB),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 13,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: const Color(0xFF9CA3AF),
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscurePassword = !_obscurePassword;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          SizedBox(
                                            height: 18,
                                            child: _passwordError != null
                                                ? Text(
                                                    _passwordError!,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                      // Confirmar contraseña
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Confirmar contraseña',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _confirmPasswordController,
                                            obscureText: _obscureConfirmPassword,
                                            onChanged: (_) {
                                              if (_confirmPasswordError != null) {
                                                setState(() {
                                                  _confirmPasswordError = null;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Repite la contraseña',
                                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                                              filled: true,
                                              fillColor: const Color(0xFFF9FAFB),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 13,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: const Color(0xFF9CA3AF),
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          SizedBox(
                                            height: 18,
                                            child: _confirmPasswordError != null
                                                ? Text(
                                                    _confirmPasswordError!,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // Botón Crear cuenta
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _validateAndSubmit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF22C55E),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  'Crear cuenta',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Link a Login
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            '¿Ya tienes cuenta?',
                                            style: TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: const Text(
                                              'Inicia sesión',
                                              style: TextStyle(
                                                color: Color(0xFF22C55E),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  '© 2025 TaskFlow',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}