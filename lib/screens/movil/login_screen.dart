import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/movil/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _busy = false;
  bool _obscure = true;
  bool _accepted = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_accepted || _email.text.trim().isEmpty || _password.text.isEmpty) {
      _message('Completa tu correo, contraseña y acepta los términos.');
      return;
    }
    setState(() => _busy = true);
    try {
      await _auth.signIn(_email.text, _password.text);
    } catch (_) {
      if (mounted) _message('Correo o contraseña incorrectos. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (_email.text.trim().isEmpty) {
      _message('Escribe tu correo para recuperar tu contraseña.');
      return;
    }
    try {
      await _auth.resetPassword(_email.text);
      if (mounted) _message('Te enviamos un enlace para recuperar tu contraseña.');
    } catch (_) {
      if (mounted) _message('No se pudo enviar el enlace. Verifica tu correo.');
    }
  }

  void _message(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(constraints.maxWidth - 32, 420.0);
            return Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: width,
                  height: 650,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 190,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1206322B),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 94,
                              height: 94,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE9F4EC),
                              ),
                              child: ClipOval(
                                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'EIVET',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: const Color(0xFF06322B),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Iniciar sesión',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF06322B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _field(_email, 'Ingresa tu correo', Icons.mail_outline),
                            const SizedBox(height: 12),
                            _field(_password, 'Contraseña', Icons.lock_outline, password: true),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _reset,
                                child: const Text('¿Olvidaste tu contraseña?'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton(
                                onPressed: _busy ? null : _login,
                                child: _busy
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white),
                                      )
                                    : const Text('Continuar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Checkbox(
                                    value: _accepted,
                                    onChanged: (value) => setState(() => _accepted = value ?? false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Acepto los términos y la política de privacidad.',
                                    style: TextStyle(fontSize: 13, height: 1.25),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('¿Nuevo aquí?'),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
                                    ),
                                    child: const Text('Regístrate'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool password = false,
  }) =>
      TextField(
        controller: controller,
        obscureText: password && _obscure,
        keyboardType: password ? TextInputType.text : TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: password
              ? IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xFFBECAB9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xFFBECAB9)),
          ),
        ),
      );
}
