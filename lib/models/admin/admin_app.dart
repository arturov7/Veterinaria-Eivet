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

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'EIVET Administración',
    theme: AdminTheme.light(),
    home:
        c.read<AppConfig>().requestedMode == AppMode.supabase &&
            !c.read<AppConfig>().useSupabase
        ? const Scaffold(
            body: Center(
              child: Text(
                'Configura Supabase con --dart-define-from-file=.env para abrir el panel.',
              ),
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
    final wide = MediaQuery.sizeOf(c).width >= 1100;
    final screens = [
      AdminDashboardScreen(userName: auth.name),
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
                  showMenu: !wide,
                  name: auth.name,
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onNewConsultation: () => setState(() => index = 4),
                  onLogout: auth.logout,
                ),
                Expanded(
                  child: screens[safeIndex] is AdminDashboardScreen
                      ? AdminDashboardScreen(
                          userName: auth.name,
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
    required this.showMenu,
    required this.name,
    required this.onMenu,
    required this.onNewConsultation,
    required this.onLogout,
  });
  final String title, name;
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
