import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/workspace_repository.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/profile/profile_bloc.dart';
import 'logic/category/category_bloc.dart';
import 'logic/task/task_bloc.dart';
import 'logic/workspace/workspace_bloc.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => TaskRepository()),
        RepositoryProvider(create: (context) => CategoryRepository()),
        RepositoryProvider(create: (context) => WorkspaceRepository()),
        RepositoryProvider(create: (context) => ProfileRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(AuthCheckStatusEvent()),
          ),
          BlocProvider(
            create: (context) =>
                TaskBloc(taskRepository: context.read<TaskRepository>()),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(
              categoryRepository: context.read<CategoryRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => WorkspaceBloc(
              repository: context.read<WorkspaceRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(
              profileRepository: context.read<ProfileRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'TaskFlow',
          debugShowCheckedModeBanner: false,
          locale: const Locale('es', 'ES'),
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('es', ''),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: Colors.teal,
            useMaterial3: true,
            fontFamily: 'Poppins',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.teal, width: 2),
              ),
            ),
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // ✅ CORREGIDO: AuthInitial también muestra el spinner,
        // evita que se vea LoginScreen un instante al arrancar la app
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}