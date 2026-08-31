import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'controllers/context_controller.dart';
import 'controllers/preferences_controller.dart';
import 'repositories/appointment_repository.dart';
import 'repositories/demo_appointment_repository.dart';
import 'repositories/demo_registro_repository.dart';
import 'repositories/registro_repository.dart';
import 'repositories/veterinary_catalog_repository.dart';
import 'repositories/supabase_appointment_repository.dart';
import 'repositories/supabase_registro_repository.dart';
import 'services/location_service.dart';
import 'services/preferences_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  if (config.useSupabase) {
    await Supabase.initialize(url: config.supabaseUrl, publishableKey: config.supabasePublishableKey);
  }
  final prefs = await SharedPreferences.getInstance();

  final preferencesController = PreferencesController(
    PreferencesService(prefs),
  );

  final httpClient = http.Client();
  final RegistroRepository repository = config.useSupabase
      ? SupabaseRegistroRepository()
      : DemoRegistroRepository();
  final AppointmentRepository appointmentRepository = config.useSupabase
      ? SupabaseAppointmentRepository()
      : DemoAppointmentRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        Provider<http.Client>.value(value: httpClient),
        ChangeNotifierProvider<PreferencesController>.value(
          value: preferencesController,
        ),
        Provider<RegistroRepository>.value(value: repository),
        Provider<AppointmentRepository>.value(value: appointmentRepository),
        Provider<VeterinaryCatalogRepository>(
          create: (_) => VeterinaryCatalogRepository(),
        ),
        Provider<LocationService>(
          create: (providerContext) => const LocationService(),
        ),
        Provider<WeatherService>(
          create: (providerContext) => const WeatherService(),
        ),
        ChangeNotifierProvider<ContextController>(
          create: (providerContext) {
            return ContextController(
              locationService: providerContext.read<LocationService>(),
              weatherService: providerContext.read<WeatherService>(),
            );
          },
        ),
      ],
      child: const ProyectoFinalApp(),
    ),
  );
}
