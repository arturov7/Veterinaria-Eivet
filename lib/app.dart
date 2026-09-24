import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/movil/preferences_controller.dart';
import 'screens/movil/home_screen.dart';
import 'screens/movil/login_screen.dart';
import 'services/movil/auth_service.dart';
import 'core/utils/app_config.dart';
import 'core/movil/app_theme.dart';

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
      home: context.read<AppConfig>().requestedMode == AppMode.supabase
          ? context.read<AppConfig>().useSupabase
                ? const _AuthGate()
                : const _SupabaseConfigurationScreen()
          : const HomeScreen(),
    );
  }
}

class _SupabaseConfigurationScreen extends StatelessWidget {
  const _SupabaseConfigurationScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined, size: 56),
              SizedBox(height: 16),
              Text('Falta configurar Supabase', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Completa APP_MODE, SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY en config/local.json y vuelve a iniciar la app.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: AuthService().onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session ?? AuthService().currentSession;
          if (snapshot.connectionState == ConnectionState.waiting && session == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return session == null
              ? const LoginScreen()
              : HomeScreen(key: ValueKey(session.user.id));
        },
      );
}
