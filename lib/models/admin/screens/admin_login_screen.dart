import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_auth_controller.dart';
import '../utils/admin_validators.dart';
import '../utils/admin_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _LoginState();
}

class _LoginState extends State<AdminLoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(text: 'admin@eivet.demo'),
      pass = TextEditingController(text: 'demo123');
  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final a = c.watch<AdminAuthController>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff8f9ff), Color(0xffe5eeff)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AdminTheme.forest,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 34,
                          color: Color(0xff93f3bb),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Veterinaria EIVET',
                        style: Theme.of(c).textTheme.headlineSmall,
                      ),
                      const Text('Panel administrativo'),
                      const SizedBox(height: 8),
                      const Text(
                        'Acceso seguro para el personal veterinario',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AdminTheme.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: email,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                        ),
                        validator: AdminValidators.email,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: pass,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        validator: (v) =>
                            AdminValidators.required(v, 'La contraseña'),
                      ),
                      if (a.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            a.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: a.loading
                              ? null
                              : () async {
                                  if (form.currentState!.validate())
                                    await a.login(email.text, pass.text);
                                },
                          child: Text(
                            a.loading ? 'Ingresando...' : 'Ingresar al panel',
                          ),
                        ),
                      ),
                      if (!a.config.useSupabase)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Modo DEMO: usa cualquier correo y contraseña.',
                            textAlign: TextAlign.center,
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
    );
  }
}
