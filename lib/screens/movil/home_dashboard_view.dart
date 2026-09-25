import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controllers/movil/preferences_controller.dart';
import '../../core/utils/app_config.dart';
import '../../models/movil/veterinary_content.dart';
import '../../repositories/movil/veterinary_catalog_repository.dart';
import '../../services/movil/auth_service.dart';
import 'records_screen.dart';

class HomeDashboardView extends StatefulWidget {
  const HomeDashboardView({super.key, required this.onMenu});

  final VoidCallback onMenu;

  @override
  State<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<HomeDashboardView> {
  static const emerald = Color(0xFF087B55);
  List<Map<String, dynamic>> _notifications = const [];
  String? _notificationError;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!context.read<AppConfig>().useSupabase) return;
    final userId = AuthService().getCurrentUser()?.id;
    if (userId == null) return;
    try {
      final rows = await Supabase.instance.client
          .from('notificaciones')
          .select('id,titulo,mensaje,leida,created_at')
          .eq('cliente_id', userId)
          .order('created_at', ascending: false)
          .limit(20);
      if (!mounted) return;
      setState(() {
        _notifications = (rows as List)
            .map((row) => Map<String, dynamic>.from(row as Map))
            .toList();
        _notificationError = null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _notificationError = 'No se pudieron cargar las notificaciones.',
        );
      }
    }
  }

  Future<void> _openNotifications() async {
    await _loadNotifications();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .65,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                if (_notificationError != null)
                  Text(_notificationError!)
                else if (_notifications.isEmpty)
                  const Text('No tienes notificaciones por ahora.')
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            item['leida'] == true
                                ? Icons.notifications_none_outlined
                                : Icons.notifications_active_outlined,
                            color: emerald,
                          ),
                          title: Text(item['titulo']?.toString() ?? 'Aviso'),
                          subtitle: Text(item['mensaje']?.toString() ?? ''),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<PreferencesController>();
    final catalog = context.watch<VeterinaryCatalogRepository>();
    final user = AuthService().getCurrentUser();
    final metadataName =
        user?.userMetadata?['full_name']?.toString().trim() ?? '';
    final accountName = user?.email?.split('@').first ?? '';
    final displayName = preferences.name.trim().isNotEmpty
        ? preferences.name.trim()
        : metadataName.isNotEmpty
        ? metadataName
        : accountName.isNotEmpty
        ? accountName
        : 'bienvenido';
    final firstName = displayName.split(RegExp(r'\s+')).first;
    final hasUnread = _notifications.any((item) => item['leida'] != true);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF152D28),
          surfaceTintColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            tooltip: 'Abrir menú',
            onPressed: widget.onMenu,
            icon: const Icon(Icons.menu_rounded, size: 27),
          ),
          title: Row(
            children: [
              Image.asset('assets/logo.png', width: 38, height: 38),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Veterinaria EIVET',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'PANEL VETERINARIO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .9,
                        color: Color(0xFF53675F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  tooltip: 'Notificaciones',
                  onPressed: _openNotifications,
                  icon: const Icon(Icons.notifications_none_rounded, size: 27),
                ),
                if (hasUnread)
                  const Positioned(
                    right: 9,
                    top: 9,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFFE53443),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WelcomeBanner(firstName: firstName),
                    const SizedBox(height: 18),
                    _SearchCard(
                      onTap: () => _notice(
                        context,
                        'Busca un servicio o revisa las fichas de tus mascotas.',
                      ),
                    ),
                    const SizedBox(height: 27),
                    _SectionHeading(
                      title: 'Servicios',
                      onSeeAll: () => _notice(
                        context,
                        'Consulta nuestros servicios en recepción.',
                      ),
                    ),
                    const SizedBox(height: 15),
                    _ServicesRow(
                      services: catalog.services,
                      onTap: (service) => _handleService(context, service),
                    ),
                    const SizedBox(height: 28),
                    _SectionHeading(
                      title: 'Servicios destacados',
                      onSeeAll: () => _notice(
                        context,
                        'Consulta nuestros servicios en recepción.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final service in catalog.featuredServices) ...[
                      _FeaturedCard(
                        service: service,
                        onPressed: () => _handleService(context, service),
                      ),
                      const SizedBox(height: 13),
                    ],
                  ],
                ),
              ),
            ),
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

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) => Container(
    height: 150,
    decoration: BoxDecoration(
      color: const Color(0xFFE9FBF3),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x100E5A43),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -24,
            child: CircleAvatar(
              radius: 92,
              backgroundColor: const Color(0xFFD6F4E7),
              child: Image.asset(
                'assets/eivet_welcome_dog.png',
                width: 151,
                height: 176,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 132, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hola, $firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 23,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF173A30),
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  '¿Cómo podemos ayudar\na tus pacientes hoy?',
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color: Color(0xFF49685D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 5,
    shadowColor: const Color(0x17074131),
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        height: 61,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFE9F1EE)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: Color(0xFF3C5852), size: 25),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Buscar clínicas, servicios, mascotas...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Color(0xFF80928C), fontSize: 14),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.tune_rounded, color: Color(0xFF3C5852), size: 23),
          ],
        ),
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Color(0xFF182E28),
          ),
        ),
      ),
      TextButton(
        onPressed: onSeeAll,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF087B55),
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
        child: const Text(
          'Ver todos',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _ServicesRow extends StatelessWidget {
  const _ServicesRow({required this.services, required this.onTap});
  final List<VeterinaryService> services;
  final ValueChanged<VeterinaryService> onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final tileSize = math.min(77.0, (constraints.maxWidth - 36) / 4);
      const colors = [
        Color(0xFF0D9A72),
        Color(0xFFE1F9EF),
        Color(0xFFFFE9AD),
        Color(0xFFDDEBFF),
      ];
      const iconColors = [
        Colors.white,
        Color(0xFF087B55),
        Color(0xFFE88C28),
        Color(0xFF2863C8),
      ];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var index = 0; index < services.length; index++)
            SizedBox(
              width: tileSize,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onTap(services[index]),
                child: Column(
                  children: [
                    Container(
                      width: tileSize,
                      height: tileSize,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x100E5A43),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        services[index].icon,
                        size: 30,
                        color: iconColors[index % iconColors.length],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      services[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF28413B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.service, required this.onPressed});
  final VeterinaryService service;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFF8FFFB),
    borderRadius: BorderRadius.circular(20),
    elevation: 3,
    shadowColor: const Color(0x1303382B),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 105),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8F3EC)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: service.title.startsWith('Vacun')
                  ? const Color(0xFFD7F8C8)
                  : const Color(0xFFC9F4E6),
              child: Icon(
                service.icon,
                size: 31,
                color: const Color(0xFF096D4D),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D352E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.subtitle,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Color(0xFF647D72),
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF395B50)),
          ],
        ),
      ),
    ),
  );
}
