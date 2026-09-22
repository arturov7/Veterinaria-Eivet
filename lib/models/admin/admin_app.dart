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

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'EIVET Administración',
    theme: AdminTheme.light(),
    home: const _Gate(),
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
  Widget build(BuildContext c) {
    final auth = c.watch<AdminAuthController>();
    final wide = MediaQuery.sizeOf(c).width >= 900;
    final screens = [
      const AdminDashboardScreen(),
      const OwnersScreen(),
      const PetsScreen(),
      RecordsScreen(
        title: 'Citas',
        type: 'citas',
        controller: c.watch<AppointmentsController>(),
      ),
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
    final sidebar = AdminSidebar(
      index: index,
      name: auth.name,
      role: auth.role,
      onLogout: auth.logout,
      onSelect: (v) => setState(() => index = v),
    );
    return Scaffold(
      key: _scaffoldKey,
      drawer: wide
          ? null
          : Drawer(
              width: 280,
              child: AdminSidebar(
                index: index,
                name: auth.name,
                role: auth.role,
                onLogout: auth.logout,
                onSelect: (v) {
                  setState(() => index = v);
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
                  title: AdminSidebar.labels[index],
                  showMenu: !wide,
                  name: auth.name,
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: screens[index] is AdminDashboardScreen
                      ? AdminDashboardScreen(
                          onNavigate: (v) => setState(() => index = v),
                        )
                      : screens[index],
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
  });
  final String title, name;
  final bool showMenu;
  final VoidCallback onMenu;
  @override
  Widget build(BuildContext context) => Container(
    height: 68,
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar en el panel…',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        if (MediaQuery.sizeOf(context).width > 1050)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Color(0xff1b8354)),
                SizedBox(width: 7),
                Text(
                  'Atención veterinaria',
                  style: TextStyle(fontSize: 11, color: Color(0xff414844)),
                ),
              ],
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
        const SizedBox(width: 4),
        CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xff0f382a),
          child: Text(
            name.isEmpty ? 'E' : name.trim()[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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
        ],
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
    ChangeNotifierProvider(create: (_) => OwnersController(r)..load()),
    ChangeNotifierProvider(create: (_) => PetsController(r)..load()),
    ChangeNotifierProvider(create: (_) => AppointmentsController(r)..load()),
    ChangeNotifierProvider(create: (_) => ConsultationsController(r)..load()),
    ChangeNotifierProvider(create: (_) => TreatmentsController(r)..load()),
    ChangeNotifierProvider(create: (_) => VaccinesController(r)..load()),
  ];
}
