import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/utils/app_config.dart';
import 'controllers/movil/context_controller.dart';
import 'controllers/movil/preferences_controller.dart';
import 'repositories/movil/appointment_repository.dart';
import 'repositories/movil/demo_appointment_repository.dart';
import 'repositories/movil/demo_registro_repository.dart';
import 'repositories/movil/demo_pet_care_repository.dart';
import 'repositories/movil/pet_care_repository.dart';
import 'repositories/movil/registro_repository.dart';
import 'repositories/movil/supabase_pet_care_repository.dart';
import 'repositories/movil/veterinary_catalog_repository.dart';
import 'repositories/movil/supabase_appointment_repository.dart';
import 'repositories/movil/supabase_registro_repository.dart';
import 'services/movil/location_service.dart';
import 'services/movil/preferences_service.dart';
import 'services/movil/weather_service.dart';
import 'models/admin/admin_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  if (config.useSupabase) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
    );
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
  final PetCareRepository petCareRepository = config.useSupabase
      ? SupabasePetCareRepository()
      : const DemoPetCareRepository();

  runApp(
    MultiProvider(
      providers: [
        ...adminProviders(config),
        Provider<AppConfig>.value(value: config),
        Provider<http.Client>.value(value: httpClient),
        ChangeNotifierProvider<PreferencesController>.value(
          value: preferencesController,
        ),
        Provider<RegistroRepository>.value(value: repository),
        Provider<AppointmentRepository>.value(value: appointmentRepository),
        Provider<PetCareRepository>.value(value: petCareRepository),
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
      child: kIsWeb ? const AdminApp() : const ProyectoFinalApp(),
    ),
  );
}
