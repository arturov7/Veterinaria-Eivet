import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_config.dart';
import 'admin_repository.dart';
import 'controllers/admin_auth_controller.dart';
import 'controllers/admin_controller.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_crud_screens.dart';
import 'utils/admin_theme.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/eivet_logo.dart';
import 'widgets/eivet_hero_banner.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'EIVET Administración',
    theme: AdminTheme.light(),
    home: c.read<AppConfig>().requestedMode == AppMode.supabase &&
            !c.read<AppConfig>().useSupabase
        ? const Scaffold(
            body: Center(
              child: Text('Configura Supabase con --dart-define-from-file=config/local.json para abrir el panel.'),
            ),
          )
        : const _Gate(),
  );
}

class _Gate extends StatelessWidget {
  const _Gate();
  @override
  Widget build(BuildContext c) => c.watch<AdminAuthController>().authenticated
      ? const _Shell()
      : const AdminLoginScreen();
}

class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OwnersController>().load();
      context.read<PetsController>().load();
      context.read<AppointmentsController>().load();
      context.read<ConsultationsController>().load();
      context.read<TreatmentsController>().load();
      context.read<VaccinesController>().load();
    });
  }
  @override
  Widget build(BuildContext c) {
    final auth = c.watch<AdminAuthController>();
    final config = c.watch<AppConfig>();
    final wide = MediaQuery.sizeOf(c).width >= 1100;
    final screens = [
      const AdminDashboardScreen(),
      RecordsScreen(
        title: 'Citas veterinarias',
        type: 'citas',
        controller: c.watch<AppointmentsController>(),
      ),
      const OwnersScreen(),
      const PetsScreen(),
      RecordsScreen(
        title: 'Consultas e historial clínico',
        type: 'consultas',
        controller: c.watch<ConsultationsController>(),
      ),
      _Care(
        treatments: c.watch<TreatmentsController>(),
        vaccines: c.watch<VaccinesController>(),
      ),
      _OncologyScreen(onOpenRecords: () => setState(() => index = 4)),
      _ReportsScreen(
        owners: c.watch<OwnersController>().items.length,
        pets: c.watch<PetsController>().items.length,
        appointments: c.watch<AppointmentsController>().items.length,
        consultations: c.watch<ConsultationsController>().items.length,
      ),
      const _SettingsScreen(),
    ];
    final safeIndex = index.clamp(0, screens.length - 1).toInt();
    final sidebar = AdminSidebar(
      index: safeIndex,
      name: auth.name,
      role: auth.role,
      onLogout: auth.logout,
      onSelect: (v) =>
          setState(() => index = v.clamp(0, screens.length - 1).toInt()),
    );
    return Scaffold(
      key: _scaffoldKey,
      drawer: wide
          ? null
          : Drawer(
              width: 304,
              child: AdminSidebar(
                index: safeIndex,
                name: auth.name,
                role: auth.role,
                onLogout: auth.logout,
                onSelect: (v) {
                  setState(
                    () => index = v.clamp(0, screens.length - 1).toInt(),
                  );
                  Navigator.pop(c);
                },
              ),
            ),
      body: Row(
        children: [
          if (wide) sidebar,
          Expanded(
            child: Column(
              children: [
                _AdminTopBar(
                  title: AdminSidebar.labels[safeIndex],
                  dataMode: config.useSupabase ? 'SUPABASE' : 'DEMO',
                  showMenu: !wide,
                  name: auth.name,
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onNewConsultation: () => setState(() => index = 4),
                  onLogout: auth.logout,
                ),
                Expanded(
                  child: screens[safeIndex] is AdminDashboardScreen
                      ? AdminDashboardScreen(
                          onNavigate: (v) => setState(
                            () =>
                                index = v.clamp(0, screens.length - 1).toInt(),
                          ),
                        )
                      : screens[safeIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.title,
    required this.dataMode,
    required this.showMenu,
    required this.name,
    required this.onMenu,
    required this.onNewConsultation,
    required this.onLogout,
  });
  final String title, name, dataMode;
  final bool showMenu;
  final VoidCallback onMenu;
  final VoidCallback onNewConsultation;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) => Container(
    height: 78,
    padding: const EdgeInsets.symmetric(horizontal: 22),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xffe2e8f0))),
    ),
    child: Row(
      children: [
        if (showMenu)
          IconButton(onPressed: onMenu, icon: const Icon(Icons.menu)),
        if (showMenu) const SizedBox(width: 6),
        Expanded(
          flex: 5,
          child: Semantics(
            label: title,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar en el panel…',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        if (MediaQuery.sizeOf(context).width > 1050)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xffedf2ff),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Color(0xff1b8354)),
                SizedBox(width: 7),
                Text(
                  'Turno Activo: Quirófano • 08:30 - 18:00',
                  style: TextStyle(fontSize: 11, color: Color(0xff414844)),
                ),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: dataMode == 'SUPABASE'
                ? const Color(0xffe8f5ee)
                : const Color(0xfffff4d6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            dataMode,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: dataMode == 'SUPABASE'
                  ? const Color(0xff167044)
                  : const Color(0xff8a5b00),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Notificaciones',
          icon: const Badge(
            smallSize: 8,
            child: Icon(Icons.notifications_none_outlined),
          ),
        ),
        if (MediaQuery.sizeOf(context).width > 700) ...[
          const SizedBox(width: 6),
          FilledButton.icon(
            onPressed: onNewConsultation,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nueva Consulta'),
          ),
        ],
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          tooltip: 'Cuenta personal',
          onSelected: (value) {
            if (value == 'logout') onLogout();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
          ],
          child: Row(
            children: [
              const EivetLogo(size: 40),
              if (MediaQuery.sizeOf(context).width > 700) ...[
                const SizedBox(width: 9),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff0b1c30),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AdminTheme.muted,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _Care extends StatelessWidget {
  const _Care({required this.treatments, required this.vaccines});
  final TreatmentsController treatments;
  final VaccinesController vaccines;
  @override
  Widget build(BuildContext c) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        const TabBar(
          tabs: [
            Tab(text: 'Tratamientos'),
            Tab(text: 'Vacunas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              RecordsScreen(
                title: 'Tratamientos',
                type: 'tratamientos',
                controller: treatments,
              ),
              RecordsScreen(
                title: 'Vacunas',
                type: 'vacunas',
                controller: vaccines,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _OncologyScreen extends StatelessWidget {
  const _OncologyScreen({required this.onOpenRecords});
  final VoidCallback onOpenRecords;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EivetHeroBanner(
          kicker: 'Unidad especializada • EIVET',
          title: 'Oncología Veterinaria',
          subtitle:
              'Seguimiento clínico integral para pacientes oncológicos y sus familias.',
          icon: Icons.biotech_outlined,
          accent: const Color(0xfff2c14e),
          actions: FilledButton.icon(
            onPressed: onOpenRecords,
            icon: const Icon(Icons.medical_information_outlined),
            label: const Text('Abrir historial clínico'),
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 560
                ? 2
                : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.65,
              children: const [
                _OncologyTile(
                  icon: Icons.biotech_outlined,
                  title: 'Protocolos clínicos',
                  detail: 'Registro de diagnósticos y planes de seguimiento.',
                  color: Color(0xffe3f7ed),
                ),
                _OncologyTile(
                  icon: Icons.medication_outlined,
                  title: 'Tratamientos',
                  detail: 'Consulta las indicaciones y controles registrados.',
                  color: Color(0xfffff2d5),
                ),
                _OncologyTile(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Evolución del paciente',
                  detail:
                      'Mantén las notas clínicas vinculadas a cada consulta.',
                  color: Color(0xffe6f2ff),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _OncologyTile extends StatelessWidget {
  const _OncologyTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
  });
  final IconData icon;
  final String title, detail;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AdminTheme.emerald, size: 25),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            style: const TextStyle(fontSize: 12, color: AdminTheme.muted),
          ),
        ],
      ),
    ),
  );
}

class _ReportsScreen extends StatelessWidget {
  const _ReportsScreen({
    required this.owners,
    required this.pets,
    required this.appointments,
    required this.consultations,
  });
  final int owners, pets, appointments, consultations;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EivetHeroBanner(
          kicker: 'Centro Veterinario • Estadísticas',
          title: 'Reportes EIVET',
          subtitle:
              'Resumen de registros y actividad disponible en el sistema.',
          icon: Icons.analytics_outlined,
          accent: Color(0xfff2c14e),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 560
                ? 2
                : 1;
            final metrics = [
              (
                'Clientes y propietarios',
                owners,
                Icons.groups_outlined,
                const Color(0xffe3f7ed),
              ),
              ('Pacientes', pets, Icons.pets_outlined, const Color(0xffe6f2ff)),
              (
                'Citas',
                appointments,
                Icons.calendar_month_outlined,
                const Color(0xfffff2d5),
              ),
              (
                'Consultas',
                consultations,
                Icons.medical_information_outlined,
                const Color(0xffffeaf0),
              ),
            ];
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.45,
              children: metrics
                  .map(
                    (metric) => Card(
                      color: metric.$4,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(metric.$3, color: AdminTheme.emerald),
                            const Spacer(),
                            Text(
                              '${metric.$2}',
                              style: const TextStyle(
                                fontSize: 28,
                                color: AdminTheme.forest,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              metric.$1,
                              style: const TextStyle(
                                color: AdminTheme.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    ),
  );
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EivetHeroBanner(
          kicker: 'Centro Veterinario • EIVET',
          title: 'Configuración / Seguridad',
          subtitle:
              'Personaliza tu clínica, gestiona usuarios, turnos y preferencias del sistema.',
          icon: Icons.shield_outlined,
          accent: Color(0xffedb848),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.cloud_done_outlined,
              color: AdminTheme.emerald,
            ),
            title: const Text('Base de datos Supabase'),
            subtitle: const Text(
              'Conexión configurada para sincronizar la clínica.',
            ),
            trailing: const Chip(label: Text('Conectada')),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.verified_user_outlined,
              color: AdminTheme.emerald,
            ),
            title: const Text('Autenticación segura'),
            subtitle: const Text(
              'Acceso de personal veterinario protegido mediante Supabase Auth.',
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.palette_outlined,
              color: AdminTheme.emerald,
            ),
            title: const Text('Identidad EIVET'),
            subtitle: const Text(
              'Paleta clínica verde y escudo oficial de la veterinaria.',
            ),
          ),
        ),
      ],
    ),
  );
}

List<dynamic> adminProviders(AppConfig config) {
  final r = config.useSupabase
      ? SupabaseAdminRepository()
      : DemoAdminRepository();
  return [
    Provider<AdminRepository>.value(value: r),
    ChangeNotifierProvider(create: (_) => AdminAuthController(config)),
    ChangeNotifierProvider(create: (_) => OwnersController(r)),
    ChangeNotifierProvider(create: (_) => PetsController(r)),
    ChangeNotifierProvider(create: (_) => AppointmentsController(r)),
    ChangeNotifierProvider(create: (_) => ConsultationsController(r)),
    ChangeNotifierProvider(create: (_) => TreatmentsController(r)),
    ChangeNotifierProvider(create: (_) => VaccinesController(r)),
  ];
}
