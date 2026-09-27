import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_auth_controller.dart';
import '../utils/admin_theme.dart';
import '../utils/admin_validators.dart';
import '../widgets/eivet_logo.dart';

const _loginInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(color: Color(0xffd7e1e5)),
);
const _loginFocusedInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(color: AdminTheme.emerald, width: 1.5),
);

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _LoginState();
}

class _LoginState extends State<AdminLoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass = TextEditingController(text: 'demo123');
  bool remember = true, reveal = false;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthController>();
    final screenSize = MediaQuery.sizeOf(context);
    final wide = screenSize.width >= 1100;
    final widthScale = (screenSize.width / 1680).clamp(.62, 1.0).toDouble();
    final heightScale = (screenSize.height / 945).clamp(.62, 1.0).toDouble();
    final scale = wide ? math.min(1.0, widthScale * 1.12) : 1.0;
    final gapScale = wide && screenSize.height < 760
        ? heightScale * .68
        : scale;
    final loginCardWidth = wide
        ? math.min(
            820 * widthScale,
            screenSize.width * 7 / 13 - 40 * widthScale,
          )
        : 620.0;
    final panel = LayoutBuilder(
      builder: (context, panelConstraints) {
        final fillHeight = wide && panelConstraints.hasBoundedHeight
            ? panelConstraints.maxHeight
            : 0.0;
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 0 : 18,
              vertical: wide ? 0 : 30,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: loginCardWidth,
                minHeight: fillHeight,
              ),
              child: Container(
            padding: wide
                ? EdgeInsets.fromLTRB(
                    40 * widthScale,
                    (screenSize.height < 760 ? 32 : 38) * scale,
                    40 * widthScale,
                    (screenSize.height < 760 ? 22 : 24) * scale,
                  )
                : const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23 * scale),
              border: Border.all(color: const Color(0xffedf2f1)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120b382b),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
                child: Form(
              key: form,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: EivetLogo(size: 100 * scale)),
                  SizedBox(height: 13 * gapScale),
                  Center(
                    child: Text(
                      'Iniciar Sesión',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                        fontSize: 36 * scale,
                            color: const Color(0xff092f25),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  SizedBox(height: 7 * gapScale),
                  Center(
                    child: Text(
                      'Ingresa tus credenciales del personal médico para acceder\nal panel clínico y fichas de pacientes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff71839a),
                        height: 1.45,
                        fontSize: 14 * scale,
                      ),
                    ),
                  ),
                  SizedBox(height: 32 * gapScale),
                  _FieldLabel(
                    'CORREO ELECTRÓNICO INSTITUCIONAL',
                    scale: scale,
                  ),
                  SizedBox(height: 7 * gapScale),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: TextStyle(
                      color: AdminTheme.ink,
                      fontSize: 14 * scale,
                    ),
                    validator: AdminValidators.email,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.mail_outline),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 40 * scale,
                        minHeight: 36 * scale,
                      ),
                      hintText: 'admin@eivet.demo',
                      hintStyle: TextStyle(
                        color: AdminTheme.muted.withValues(alpha: .55),
                        fontSize: 14 * scale,
                      ),
                      border: _loginInputBorder,
                      enabledBorder: _loginInputBorder,
                      focusedBorder: _loginFocusedInputBorder,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14 * widthScale,
                        vertical: 13 * scale,
                      ),
                    ),
                  ),
                  SizedBox(height: 14 * gapScale),
                  _FieldLabel('CONTRASEÑA', scale: scale),
                  SizedBox(height: 7 * gapScale),
                  TextFormField(
                    controller: pass,
                    style: TextStyle(
                      color: AdminTheme.muted,
                      fontSize: 14 * scale,
                    ),
                    obscureText: !reveal,
                    validator: (v) =>
                        AdminValidators.required(v, 'La contraseña'),
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 40 * scale,
                        minHeight: 36 * scale,
                      ),
                      hintText: '••••••••',
                      border: _loginInputBorder,
                      enabledBorder: _loginInputBorder,
                      focusedBorder: _loginFocusedInputBorder,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14 * widthScale,
                        vertical: 13 * scale,
                      ),
                      suffixIcon: IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: BoxConstraints.tightFor(
                          width: 40 * scale,
                          height: 36 * scale,
                        ),
                        onPressed: () => setState(() => reveal = !reveal),
                        icon: Icon(
                          reveal
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.sizeOf(context).width < 1100) ...[
                    Row(
                      children: [
                        Checkbox(
                          value: remember,
                          onChanged: (v) =>
                              setState(() => remember = v ?? false),
                          activeColor: AdminTheme.emerald,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: Text(
                            'Recordar sesión en este equipo',
                            style: TextStyle(
                              fontSize: 13 * scale,
                              color: AdminTheme.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _ForgotPasswordLink(scale: scale),
                    ),
                  ] else
                    Row(
                      children: [
                        Checkbox(
                          value: remember,
                          onChanged: (v) =>
                              setState(() => remember = v ?? false),
                          activeColor: AdminTheme.emerald,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: Text(
                            'Recordar sesión en este equipo',
                            style: TextStyle(
                              fontSize: 13 * scale,
                              color: AdminTheme.muted,
                            ),
                          ),
                        ),
                        _ForgotPasswordLink(scale: scale),
                      ],
                    ),
                  if (auth.error != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12 * scale),
                      child: Text(
                        auth.error!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13 * scale,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 58 * scale,
                    child: FilledButton.icon(
                      onPressed: auth.loading
                          ? null
                          : () async {
                              if (form.currentState!.validate()) {
                                await auth.login(email.text, pass.text);
                              }
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: Size.fromHeight(58 * scale),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * widthScale,
                        ),
                        textStyle: TextStyle(fontSize: 14 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30 * scale),
                        ),
                      ),
                      icon: Icon(Icons.arrow_forward, size: 20 * scale),
                      label: Text(
                        auth.loading
                            ? 'Ingresando...'
                            : 'Ingresar al Portal Clínico',
                      ),
                    ),
                  ),
                ],
              ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xffeff6f4),
      body: wide
          ? Row(
              children: [
                Expanded(flex: 12, child: const _WelcomePanel()),
                Expanded(
                  flex: 14,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xfff4f9f7), Color(0xffeaf4f1)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 34,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xffb4d9c2), Color(0xffedf6f2)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  22 * widthScale,
                                  18 * scale,
                                  22 * widthScale,
                                  8 * scale,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: loginCardWidth,
                                    child: panel,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                28 * widthScale,
                                0,
                                28 * widthScale,
                                3 * scale,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Privacidad de Datos',
                                    style: TextStyle(
                                      color: AdminTheme.muted,
                                      fontSize: 11 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    '•',
                                    style: TextStyle(color: AdminTheme.muted),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Guías Clínicas',
                                    style: TextStyle(
                                      color: AdminTheme.muted,
                                      fontSize: 11 * scale,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.language,
                                    size: 14 * scale,
                                    color: AdminTheme.muted,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'ES (Latam)',
                                    style: TextStyle(
                                      color: AdminTheme.muted,
                                    fontSize: 11 * scale,
                                    ),
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
              ],
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(children: [const _MobileLoginBrand(), panel]),
              ),
            ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.scale = 1});
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 11 * scale,
      letterSpacing: .8 * scale,
      color: AdminTheme.ink,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () {},
    style: TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      minimumSize: Size(0, 40 * scale),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(
      '¿Olvidaste tu contraseña?',
      textAlign: TextAlign.end,
      style: TextStyle(
        color: AdminTheme.emerald,
        fontSize: 12 * scale,
        decoration: TextDecoration.underline,
      ),
    ),
  );
}

class _MobileLoginBrand extends StatelessWidget {
  const _MobileLoginBrand();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff07523d), Color(0xff002d23)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        const EivetLogo(size: 48),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SISTEMA HOSPITALARIO INTEGRADO',
                style: TextStyle(
                  color: Color(0xffb6e9d4),
                  fontSize: 8,
                  letterSpacing: .5,
                ),
              ),
              Text(
                'VETERINARIA EIVET',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'CIENCIA  •  COMPASIÓN  •  VIDA',
                style: TextStyle(
                  color: Color(0xffb6e9d4),
                  fontSize: 8,
                  letterSpacing: .4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        const Icon(
          Icons.volunteer_activism_outlined,
          color: Color(0xffffd263),
          size: 20,
        ),
      ],
    ),
  );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final screenSize = MediaQuery.sizeOf(context);
      final scale = math
          .min(
            (screenSize.width / 1680).clamp(.62, 1.0),
            (screenSize.height / 945).clamp(.62, 1.0),
          )
          .toDouble();
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff07523d),
                    Color(0xff00392d),
                    Color(0xff002d23),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _LoginHeroShapes())),
          Positioned(
            right: -45,
            top: -125,
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                color: Color(0x1600d89a),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 34 * scale,
            top: constraints.maxHeight * .19,
            width: constraints.maxWidth * .78,
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34 * scale,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.7,
                ),
                children: [
                  const TextSpan(text: 'Cuidado especializado,\n'),
                  const TextSpan(
                    text: 'compasión y atención avanzada',
                    style: TextStyle(color: Color(0xffffd263)),
                  ),
                  const TextSpan(text: '\npara tus pacientes.'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 30 * scale,
            top: 30 * scale,
            child: EivetLogo(size: 104 * scale),
          ),
          Positioned(
            right: -25 * scale,
            bottom: 0,
            width: constraints.maxWidth * .76,
            height: constraints.maxHeight * .66,
            child: IgnorePointer(
              child: Image.asset(
                'assets/eivet_pets_hero_v2.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      );
    },
  );
}
class _LoginHeroShapes extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mint = Paint()
      ..color = const Color(0xff53a87f).withValues(alpha: .18);
    final corner = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * .09, 0)
      ..cubicTo(
        size.width * .055,
        size.height * .045,
        size.width * .025,
        size.height * .07,
        0,
        size.height * .08,
      )
      ..close();
    canvas.drawPath(corner, mint);

    final rightShape = Path()
      ..moveTo(size.width * .88, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * .40)
      ..cubicTo(
        size.width * .91,
        size.height * .32,
        size.width * .95,
        size.height * .12,
        size.width * .88,
        0,
      )
      ..close();
    canvas.drawPath(rightShape, mint);

    final wave = Path()
      ..moveTo(0, size.height * .855)
      ..cubicTo(
        size.width * .30,
        size.height * .875,
        size.width * .57,
        size.height * .98,
        size.width * .91,
        size.height * .79,
      )
      ..lineTo(size.width, size.height * .765);
    final waveFill = Path.from(wave)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(waveFill, Paint()..color = const Color(0xff002820));
    canvas.drawPath(
      wave,
      Paint()
        ..color = const Color(0xffffd263)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11 * (size.width / 1034)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LoginHeroShapes oldDelegate) => false;
}
