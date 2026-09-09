import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/movil/preferences_controller.dart';
import '../../core/utils/app_config.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              Container(
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2EC),
                  borderRadius: BorderRadius.circular(42),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  size: 94,
                  color: Color(0xFF003F35),
                ),
              ),
              const SizedBox(height: 34),
              Text(
                'VETERINARIA EIVET',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF003F35),
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'El cuidado especializado que tu mascota merece.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF5E6C62),
                ),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  shape: const StadiumBorder(),
                ),
                onPressed: () async {
                  await context.read<PreferencesController>().completeWelcome();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => context.read<AppConfig>().useSupabase
                            ? const LoginScreen()
                            : const HomeScreen(),
                      ),
                    );
                  }
                },
                child: const Text('Comenzar', style: TextStyle(fontSize: 17)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Exclusivo para clientes de EIVET',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
