import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/admin_auth_controller.dart';
import '../utils/admin_theme.dart';
import '../utils/admin_validators.dart';
import '../widgets/eivet_logo.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _LoginState();
}

class _LoginState extends State<AdminLoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(text: 'admin@eivet.demo');
  final pass = TextEditingController(text: 'demo123');
  bool veterinary = true, remember = true, reveal = false;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthController>();
    final wide = MediaQuery.sizeOf(context).width >= 860;
    final panel = Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 18, vertical: 30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Container(
            padding: EdgeInsets.all(wide ? 38 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: EivetLogo(size: 88)),
                  const SizedBox(height: 13),
                  Center(
                    child: Text(
                      'Iniciar Sesión',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 32,
                        color: const Color(0xff092f25),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Center(
                    child: Text(
                      'Ingresa tus credenciales del personal médico para acceder\nal panel clínico y fichas de pacientes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff71839a),
                        height: 1.45,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xfff0f5f5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _RoleButton(
                            label: 'Veterinario Clínico',
                            icon: Icons.medical_services_outlined,
                            active: veterinary,
                            onTap: () => setState(() => veterinary = true),
                          ),
                        ),
                        Expanded(
                          child: _RoleButton(
                            label: 'Administrador',
                            icon: Icons.manage_accounts_outlined,
                            active: !veterinary,
                            onTap: () => setState(() => veterinary = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _FieldLabel('SEDE HOSPITALARIA'),
                  const SizedBox(height: 7),
                  DropdownButtonFormField<String>(
                    initialValue: 'Sede Central - Centro de Oncología y Quirófano',
                    isExpanded: true,
                    iconSize: 18,
                    selectedItemBuilder: (context) => const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sede Central - Centro de Oncología y Quirófano',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Clínica EIVET', maxLines: 1),
                      ),
                    ],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Sede Central - Centro de Oncología y Quirófano',
                        child: Text(
                          'Sede Central - Centro de Oncología y Quirófano',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Clínica EIVET',
                        child: Text('Clínica EIVET'),
                      ),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 15),
                  const _FieldLabel('CORREO ELECTRÓNICO INSTITUCIONAL'),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: email,
                    validator: AdminValidators.email,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline),
                      hintText: 'admin@eivet.demo',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const _FieldLabel('CONTRASEÑA'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: pass,
                    obscureText: !reveal,
                    validator: (v) => AdminValidators.required(v, 'La contraseña'),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => reveal = !reveal),
                        icon: Icon(
                          reveal ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: remember,
                        onChanged: (v) => setState(() => remember = v ?? false),
                        activeColor: AdminTheme.emerald,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Expanded(
                        child: Text(
                          'Recordar sesión en este equipo',
                          style: TextStyle(fontSize: 13, color: AdminTheme.muted),
                        ),
                      ),
                    ],
                  ),
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton.icon(
                      onPressed: auth.loading
                          ? null
                          : () async {
                              if (form.currentState!.validate()) {
                                await auth.login(email.text, pass.text);
                              }
                            },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        auth.loading ? 'Ingresando...' : 'Ingresar al Portal Clínico',
                      ),
                    ),
                  ),
                  if (!auth.config.useSupabase)
                    const Padding(
                      padding: EdgeInsets.only(top: 9),
                      child: Center(
                        child: Text(
                          'Modo DEMO: usa cualquier correo y contraseña.',
                          style: TextStyle(color: AdminTheme.muted, fontSize: 11),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text('o', style: TextStyle(color: AdminTheme.muted)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Acceder con Otro Usuario'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f8fa),
                      border: Border.all(color: const Color(0xffe8eef4)),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AdminTheme.emerald),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Autenticación federada segura con Supabase Auth',
                            style: TextStyle(color: AdminTheme.muted, fontSize: 11),
                          ),
                        ),
                        Text('256-bit AES', style: TextStyle(color: AdminTheme.muted, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(color: AdminTheme.muted, fontSize: 11),
                        children: [
                          TextSpan(text: '¿No posees una cuenta médica habilitada? '),
                          TextSpan(
                            text: 'Contacta a Administración EIVET',
                            style: TextStyle(
                              color: AdminTheme.emerald,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xffeff6f4),
      body: wide
          ? Row(
              children: [
                Expanded(flex: 3, child: const _WelcomePanel()),
                Expanded(
                  flex: 2,
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
                        top: 22,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xffeff6f5),
                            border: Border.all(color: const Color(0xffe2eeeb)),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, color: Color(0xff18b986), size: 10),
                              SizedBox(width: 9),
                              Text('Sistema Operativo', style: TextStyle(fontSize: 12)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('|', style: TextStyle(color: Color(0xffcbd5d5))),
                              ),
                              Text('v2.4.0', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 68),
                                child: panel,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(28, 4, 28, 16),
                              child: Row(
                                children: const [
                                  Text('Privacidad de Datos', style: TextStyle(color: AdminTheme.muted, fontSize: 11)),
                                  SizedBox(width: 12),
                                  Text('•', style: TextStyle(color: AdminTheme.muted)),
                                  SizedBox(width: 12),
                                  Text('Guías Clínicas', style: TextStyle(color: AdminTheme.muted, fontSize: 11)),
                                  Spacer(),
                                  Icon(Icons.language, size: 14, color: AdminTheme.muted),
                                  SizedBox(width: 5),
                                  Text('ES (Latam)', style: TextStyle(color: AdminTheme.muted, fontSize: 11)),
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
          : SafeArea(child: panel),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: active ? Colors.white : Colors.transparent,
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: active ? AdminTheme.emerald : AdminTheme.muted),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: active ? AdminTheme.ink : AdminTheme.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      letterSpacing: .8,
      color: AdminTheme.ink,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = constraints.maxHeight;
      final compact = height < 760;
      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff07523d), Color(0xff00392d), Color(0xff002d23)],
                ),
              ),
            ),
          ),
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
            right: 6,
            top: 120,
            child: Icon(Icons.pets, size: 48, color: Colors.white.withValues(alpha: .08)),
          ),
          Positioned(
            right: -5,
            bottom: 0,
            width: constraints.maxWidth * .47,
            height: height * (compact ? .57 : .64),
            child: IgnorePointer(
              child: Image.asset('assets/eivet_pets_hero.png', fit: BoxFit.contain, alignment: Alignment.bottomRight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 28 : 48, compact ? 24 : 38, 30, 22),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height - (compact ? 46 : 60)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const EivetLogo(size: 76),
                        const SizedBox(width: 17),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SISTEMA HOSPITALARIO INTEGRADO',
                                style: TextStyle(color: Color(0xffb6e9d4), fontSize: 12, letterSpacing: 1.2),
                              ),
                              Text(
                                'VETERINARIA EIVET',
                                style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800, height: 1.15),
                              ),
                              Text(
                                'C I E N C I A   ·   C O M P A S I Ó N   ·   V I D A',
                                style: TextStyle(color: Color(0xffb6e9d4), fontSize: 10, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .10),
                            border: Border.all(color: const Color(0x668ddabc)),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.volunteer_activism_outlined, color: Color(0xffffd263), size: 19),
                              SizedBox(width: 8),
                              Text('ONCOLOGÍA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 34 : 46),
                    SizedBox(
                      width: constraints.maxWidth * .70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Text(
                              '✦  Pioneros en Oncología y Cirugía de Alta Complejidad',
                              style: TextStyle(color: Color(0xffc5f2dc), fontSize: 12),
                            ),
                          ),
                          SizedBox(height: compact ? 24 : 31),
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 31 : 42,
                                height: 1.14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.8,
                              ),
                              children: const [
                                TextSpan(text: 'Cuidado Especializado,\n'),
                                TextSpan(text: 'compasión y ciencia avanzada', style: TextStyle(color: Color(0xffffd263))),
                                TextSpan(text: '\npara tus pacientes.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 19),
                          const Text(
                            'Acceso centralizado para médicos veterinarios oncólogos, cirujanos y personal de enfermería. Gestión de historias clínicas, quimioterapias, monitoreo de biometría y citas oncológicas.',
                            style: TextStyle(color: Color(0xffd1e9df), fontSize: 14, height: 1.5),
                          ),
                          SizedBox(height: compact ? 24 : 31),
                          Row(
                            children: const [
                              Expanded(child: _FeatureCard(icon: Icons.cloud_sync_outlined, title: 'Sincronización en la nube', headline: 'Supabase Cloud', detail: 'Datos seguros y en tiempo real desde cualquier sede.')),
                              SizedBox(width: 14),
                              Expanded(child: _FeatureCard(icon: Icons.description_outlined, title: 'Ficha Clínica v2.4', headline: 'Módulo de Oncología', detail: 'Protocolos certificados y seguimiento especializado.')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Expanded(child: _FeatureCard(icon: Icons.verified_user_outlined, title: 'Seguridad Avanzada', headline: 'SSL / TLS', detail: 'Encriptación de extremo a extremo de tus datos.')),
                              SizedBox(width: 14),
                              Expanded(child: _FeatureCard(icon: Icons.groups_2_outlined, title: 'Trabajo en Equipo', headline: 'Gestión Multisede', detail: 'Acceso coordinado para todo el personal.')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: compact ? 28 : 36),
                    SizedBox(
                      width: constraints.maxWidth * .75,
                      child: Column(
                        children: [
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 13),
                          Row(
                            children: const [
                              Icon(Icons.groups_2_outlined, color: Color(0xff53deb0), size: 24),
                              SizedBox(width: 10),
                              Expanded(child: _StatBlock(value: '+500', label: 'Pacientes oncológicos atendidos')),
                              SizedBox(width: 10),
                              Icon(Icons.pets, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Expanded(child: _StatBlock(value: '12+', label: 'Años de experiencia especializada')),
                              SizedBox(width: 10),
                              Icon(Icons.favorite, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Expanded(child: _StatBlock(value: 'Por una vida mejor', label: 'para ellos')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
      Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xffc2e2d6), fontSize: 10, height: 1.3)),
    ],
  );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.headline, required this.detail});
  final IconData icon;
  final String title, headline, detail;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 122),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      border: Border.all(color: Colors.white24),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .09), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xff64e2b6), size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xffd4f1e4), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(headline, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(detail, style: const TextStyle(color: Color(0xffb5d2c6), fontSize: 10, height: 1.35)),
            ],
          ),
        ),
      ],
    ),
  );
}
