import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/preferences_controller.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';

class ProyectoFinalApp extends StatelessWidget {
  const ProyectoFinalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<PreferencesController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Veterinaria EIVET',
      themeMode: preferences.themeMode,
      theme: AppTheme.light(),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF86C5AD),
          brightness: Brightness.dark,
        ),
      ),
      home: context.read<AppConfig>().useSupabase
          ? const _AuthGate()
          : const HomeScreen(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) => StreamBuilder<Object?>(
        stream: AuthService().onAuthStateChange.map<Object?>((_) => null),
        builder: (_, __) => AuthService().currentSession == null
            ? const LoginScreen()
            : const HomeScreen(),
      );
}
