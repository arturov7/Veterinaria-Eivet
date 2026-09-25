import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/movil/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _dark = Color(0xFF073E34);
  static const _emerald = Color(0xFF087B55);
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
      if (mounted)
        _message('Correo o contraseña incorrectos. Intenta nuevamente.');
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
      if (mounted)
        _message('Te enviamos un enlace para recuperar tu contraseña.');
    } catch (_) {
      if (mounted) _message('No se pudo enviar el enlace. Verifica tu correo.');
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final heroHeight = keyboardOpen
                ? topInset + 165.0
                : math.max(355.0, math.min(constraints.maxHeight * .48, 420.0));
            const overlap = 26.0;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _LoginHero(
                        height: heroHeight,
                        topInset: topInset,
                        compact: keyboardOpen,
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: heroHeight - overlap),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: math.max(
                              0,
                              constraints.maxHeight - heroHeight + overlap,
                            ),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(38),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x21001916),
                                blurRadius: 28,
                                offset: Offset(0, -8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  constraints.maxWidth < 350 ? 22 : 30,
                                  30,
                                  constraints.maxWidth < 350 ? 22 : 30,
                                  math.max(20, bottomInset + 16),
                                ),
                                child: _loginForm(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loginForm(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Iniciar sesión',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 29,
          height: 1.13,
          letterSpacing: -.7,
          fontWeight: FontWeight.w800,
          color: Color(0xFF102723),
        ),
      ),
      const SizedBox(height: 7),
      const Text(
        'Accede a tu panel veterinario',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, color: Color(0xFF5D6D68)),
      ),
      const SizedBox(height: 27),
      _field(
        _email,
        'Ingresa tu correo institucional',
        Icons.mail_outline_rounded,
      ),
      const SizedBox(height: 12),
      _field(
        _password,
        'Contraseña',
        Icons.lock_outline_rounded,
        password: true,
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _reset,
          style: TextButton.styleFrom(
            foregroundColor: _emerald,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        height: 58,
        child: FilledButton(
          onPressed: _busy ? null : _login,
          style: FilledButton.styleFrom(
            backgroundColor: _dark,
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: const Color(0x33073832),
            shape: const StadiumBorder(),
          ),
          child: _busy
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Text(
                  'Ingresar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
        ),
      ),
      const SizedBox(height: 13),
      const _RememberSessionRow(),
      Row(
        children: [
          Transform.scale(
            scale: .85,
            child: Checkbox(
              value: _accepted,
              activeColor: _emerald,
              onChanged: (value) => setState(() => _accepted = value ?? false),
            ),
          ),
          const Expanded(
            child: Text(
              'Acepto los términos y la política de privacidad.',
              style: TextStyle(fontSize: 12, color: Color(0xFF697873)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            const Text(
              '¿Nuevo aquí?',
              style: TextStyle(color: Color(0xFF5D6D68), fontSize: 14),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
              ),
              style: TextButton.styleFrom(foregroundColor: _emerald),
              child: const Text(
                'Regístrate',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool password = false,
  }) => SizedBox(
    height: 58,
    child: TextField(
      controller: controller,
      obscureText: password && _obscure,
      keyboardType: password ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF899A9B), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF2F4B4B), size: 23),
        suffixIcon: password
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF344F4E),
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _inputBorder(const Color(0xFFE1EAEB)),
        enabledBorder: _inputBorder(const Color(0xFFE1EAEB)),
        focusedBorder: _inputBorder(_emerald, width: 1.7),
      ),
    ),
  );

  OutlineInputBorder _inputBorder(Color color, {double width = 1.3}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _RememberSessionRow extends StatelessWidget {
  const _RememberSessionRow();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Transform.scale(
        scale: .85,
        child: Checkbox(
          value: true,
          onChanged: null,
          fillColor: const WidgetStatePropertyAll(Color(0xFF11965E)),
          checkColor: Colors.white,
        ),
      ),
      const Expanded(
        child: Text(
          'Recordar sesión en este equipo',
          style: TextStyle(fontSize: 13, color: Color(0xFF415651)),
        ),
      ),
    ],
  );
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({
    required this.height,
    required this.topInset,
    required this.compact,
  });

  final double height;
  final double topInset;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 70.0 : 100.0;
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF073D32),
                    Color(0xFF07583E),
                    Color(0xFF034A38),
                  ],
                ),
              ),
              child: CustomPaint(painter: _OrganicHeroPainter()),
            ),
          ),
          if (!compact) ...[
            const Positioned(
              left: 24,
              top: 130,
              child: _Paw(size: 45, opacity: .12, angle: -.25),
            ),
            const Positioned(
              right: 26,
              top: 92,
              child: _Paw(size: 28, opacity: .10, angle: .35),
            ),
            const Positioned(
              right: 14,
              bottom: 82,
              child: _Paw(size: 58, opacity: .15, angle: -.16),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: math.min(height - 155, topInset + 205),
              child: SizedBox(
                height: math.min(215, height * .53),
                child: Image.asset(
                  'assets/eivet_login_pets.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          Positioned(
            left: 0,
            right: 0,
            top: topInset + (compact ? 8 : 15),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: compact ? 6 : 14),
                Text(
                  'Veterinaria EIVET',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 22 : 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.35,
                    shadows: const [
                      Shadow(color: Color(0x33002018), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'CIENCIA  •  COMPASIÓN  •  VIDA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFDFEFE5),
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: compact ? 1.0 : 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Paw extends StatelessWidget {
  const _Paw({required this.size, required this.opacity, required this.angle});

  final double size;
  final double opacity;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Icon(
      Icons.pets_rounded,
      size: size,
      color: Colors.lightGreenAccent.withValues(alpha: opacity),
    ),
  );
}

class _OrganicHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final upper = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * .17)
      ..cubicTo(
        size.width * .76,
        size.height * .06,
        size.width * .57,
        size.height * .49,
        size.width * .25,
        size.height * .37,
      )
      ..quadraticBezierTo(0, size.height * .27, 0, size.height * .20)
      ..close();
    canvas.drawPath(upper, Paint()..color = const Color(0x142BA971));

    final lower = Path()
      ..moveTo(size.width, size.height * .38)
      ..cubicTo(
        size.width * .69,
        size.height * .43,
        size.width * .79,
        size.height * .82,
        size.width,
        size.height * .89,
      )
      ..close();
    canvas.drawPath(lower, Paint()..color = const Color(0x16001913));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
