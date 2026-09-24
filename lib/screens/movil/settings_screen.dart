import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_config.dart';
import '../../controllers/movil/preferences_controller.dart';
import '../../services/movil/auth_service.dart';
import 'about_adaptation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameController;

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión en EIVET?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await AuthService().signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cerrar la sesión.')),
        );
      }
    }
  }
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<PreferencesController>().name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _content();
    return widget.embedded
        ? page
        : Scaffold(
            appBar: AppBar(title: const Text('Mi perfil')),
            body: page,
          );
  }

  Widget _content() {
    final preferences = context.watch<PreferencesController>();
    final isAuthenticated = context.read<AppConfig>().useSupabase &&
        AuthService().isAuthenticated();
    final email = isAuthenticated ? AuthService().getCurrentUser()?.email : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        const Text(
          'Mi perfil',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(email == null
            ? 'Personaliza tu experiencia en EIVET.'
            : 'Sesión iniciada: $email'),
        const SizedBox(height: 22),
        Center(
          child: CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFFE5F2E9),
            child: Icon(Icons.person, size: 46, color: const Color(0xFF003F35)),
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Tu nombre',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () async {
            await preferences.setName(_nameController.text);
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil guardado en este dispositivo.'),
                ),
              );
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar cambios'),
        ),
        const SizedBox(height: 22),
        Card(
          elevation: 0,
          child: Column(
            children: <Widget>[
              SwitchListTile(
                value: preferences.darkMode,
                title: const Text('Tema oscuro'),
                subtitle: const Text('Preferencia guardada localmente'),
                secondary: const Icon(Icons.dark_mode_outlined),
                onChanged: preferences.setDarkMode,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings_ethernet_outlined),
                title: const Text('Fuente de datos'),
              subtitle: Text(isAuthenticated ? 'Cuenta conectada' : 'Modo de demostración'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre la aplicación'),
                subtitle: const Text('Información para la defensa'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutAdaptationScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isAuthenticated) ...[
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ],
    );
  }
}
