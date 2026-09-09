import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/movil/preferences_controller.dart';
import '../../models/movil/veterinary_content.dart';
import '../../repositories/movil/veterinary_catalog_repository.dart';
import 'appointments_screen.dart';
import 'pet_care_screen.dart';
import 'records_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _Dashboard(),
      const RecordsScreen(embedded: true),
      const PetCareScreen(embedded: true),
      const AppointmentsScreen(embedded: true),
      const SettingsScreen(embedded: true),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        height: 76,
        backgroundColor: const Color(0xFF06322B),
        indicatorColor: const Color(0xFFACF4A4),
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Mis mascotas',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            selectedIcon: Icon(Icons.health_and_safety),
            label: 'Cuidados',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();
  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<PreferencesController>();
    final catalog = context.watch<VeterinaryCatalogRepository>();
    final clientName = preferences.name.isEmpty ? 'cliente' : preferences.name;
    return CustomScrollView(
      slivers: <Widget>[
        const SliverAppBar(
          pinned: true,
          backgroundColor: Color(0xFF06322B),
          foregroundColor: Colors.white,
          titleSpacing: 18,
          title: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 19,
                backgroundColor: Color(0xFFBDE6D4),
                backgroundImage: AssetImage('assets/logo.png'),
              ),
              SizedBox(width: 10),
              Text('Veterinaria EIVET'),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              Text(
                'Hola, $clientName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text('¿Cómo podemos ayudar a tu mascota hoy?'),
              const SizedBox(height: 18),
              TextField(
                readOnly: true,
                onTap: () => _notice(
                  context,
                  'Busca un servicio o revisa las fichas de tus mascotas.',
                ),
                decoration: const InputDecoration(
                  hintText: 'Buscar clínicas, servicios, especialistas...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Servicios',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: _ServicesRow(
                  services: catalog.services,
                  onTap: (service) => _handleService(context, service),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Servicios destacados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _notice(
                      context,
                      'Consulta nuestros servicios en recepción.',
                    ),
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const Text('Atención especializada para tu compañero.'),
              const SizedBox(height: 12),
              for (final service in catalog.featuredServices) ...<Widget>[
                _FeaturedCard(
                  service: service,
                  onPressed: () => _handleService(context, service),
                ),
                const SizedBox(height: 14),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  void _handleService(BuildContext context, VeterinaryService service) {
    switch (service.action) {
      case ServiceAction.showNotice:
        _notice(context, service.message ?? service.subtitle);
      case ServiceAction.openPets:
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const RecordsScreen()),
        );
      case ServiceAction.openContext:
        _notice(context, 'Servicio no disponible.');
    }
  }

  void _notice(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _ServicesRow extends StatelessWidget {
  const _ServicesRow({required this.services, required this.onTap});
  final List<VeterinaryService> services;
  final ValueChanged<VeterinaryService> onTap;
  @override
  Widget build(BuildContext context) => ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: services.length,
    separatorBuilder: (_, __) => const SizedBox(width: 13),
    itemBuilder: (context, index) {
      final service = services[index];
      return SizedBox(
        width: 82,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onTap(service),
          child: Column(
            children: <Widget>[
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFF003F35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(service.icon, color: Colors.white),
              ),
              const SizedBox(height: 7),
              Text(
                service.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OncologyBanner extends StatelessWidget {
  const _OncologyBanner({required this.service, required this.onTap});
  final VeterinaryService service;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Ink(
      height: 184,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF003F35), Color(0xFF27735C)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (service.badge != null) _Label(text: service.badge!),
                  if (service.badge != null) const SizedBox(height: 9),
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    service.subtitle,
                    style: const TextStyle(color: Color(0xFFE0F2E8)),
                  ),
                ],
              ),
            ),
            Icon(service.icon, color: const Color(0xFFBDE6D4), size: 62),
          ],
        ),
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: const BoxDecoration(
      color: Color(0xFFF2C94C),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 11,
        color: Color(0xFF534000),
      ),
    ),
  );
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.service, required this.onPressed});
  final VeterinaryService service;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFC5D4C9)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: const Color(0xFFE7F2EB),
            child: Icon(service.icon, color: const Color(0xFF003F35)),
          ),
          const SizedBox(height: 12),
          Text(
            service.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 3),
          Text(
            service.subtitle,
            style: const TextStyle(color: Color(0xFF537763)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
            ),
            child: Text(service.actionLabel),
          ),
        ],
      ),
    ),
  );
}
