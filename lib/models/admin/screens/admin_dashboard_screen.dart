import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_models.dart';
import '../controllers/admin_controller.dart';
import '../utils/admin_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, this.onNavigate, this.userName = ''});
  final ValueChanged<int>? onNavigate;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final owners = context.watch<OwnersController>().items;
    final pets = context.watch<PetsController>().items;
    final appointments = context.watch<AppointmentsController>().items;
    final consultations = context.watch<ConsultationsController>().items;
    final vaccines = context.watch<VaccinesController>().items;
    final treatments = context.watch<TreatmentsController>().items;
    final today = DateUtils.dateOnly(DateTime.now());
    final todayAppointments =
        appointments
            .where(
              (item) =>
                  item.date != null && DateUtils.isSameDay(item.date, today),
            )
            .toList()
          ..sort((a, b) => a.date!.compareTo(b.date!));
    final pendingToday = todayAppointments
        .where((item) => item.status.toLowerCase() == 'pendiente')
        .length;
    final upcomingVaccines = vaccines
        .where(
          (item) =>
              item.date != null &&
              !DateUtils.dateOnly(item.date!).isBefore(today) &&
              !DateUtils.dateOnly(
                item.date!,
              ).isAfter(today.add(const Duration(days: 30))),
        )
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final desktop = width >= 1000;
        final columns = width >= 950
            ? 5
            : width >= 680
            ? 3
            : width >= 410
            ? 2
            : 1;
        final horizontalPadding = width < 600
            ? 14.0
            : width < 1000
            ? 18.0
            : 22.0;
        final statsHeight = width < 600 ? 112.0 : 124.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            17,
            horizontalPadding,
            22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WelcomeBanner(
                onNavigate: onNavigate,
                compact: !desktop,
                userName: userName,
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 12,
                  mainAxisExtent: statsHeight,
                ),
                itemBuilder: (context, index) {
                  final metrics = [
                    _Metric(
                      'Propietarios',
                      owners.length,
                      'Total registrados',
                      Icons.groups_2_outlined,
                      const Color(0xff078c5a),
                      const Color(0xffe9f8f1),
                    ),
                    _Metric(
                      'Mascotas activas',
                      pets.length,
                      'Pacientes en ficha',
                      Icons.pets_outlined,
                      const Color(0xff078c5a),
                      const Color(0xffedf8f4),
                    ),
                    _Metric(
                      'Citas de hoy',
                      todayAppointments.length,
                      '$pendingToday pendientes',
                      Icons.calendar_month_outlined,
                      const Color(0xffbd8b1e),
                      const Color(0xfffff7e6),
                    ),
                    _Metric(
                      'Consultas clínicas',
                      consultations.length,
                      'Registros en historial',
                      Icons.medical_information_outlined,
                      const Color(0xff078c5a),
                      const Color(0xffedf8f4),
                    ),
                    _Metric(
                      'Alertas médicas',
                      upcomingVaccines,
                      'Próximas vacunas',
                      Icons.notifications_active_outlined,
                      const Color(0xffd94f67),
                      const Color(0xfffff0f2),
                    ),
                  ];
                  return _MetricCard(metric: metrics[index]);
                },
              ),
              const SizedBox(height: 15),
              if (desktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _AppointmentsCard(
                        items: todayAppointments,
                        pets: pets,
                        onNavigate: onNavigate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _RightColumn(
                        pets: pets,
                        vaccines: vaccines,
                        treatments: treatments,
                        consultations: consultations,
                        onNavigate: onNavigate,
                      ),
                    ),
                  ],
                )
              else ...[
                _AppointmentsCard(
                  items: todayAppointments,
                  pets: pets,
                  onNavigate: onNavigate,
                ),
                const SizedBox(height: 14),
                _RightColumn(
                  pets: pets,
                  vaccines: vaccines,
                  treatments: treatments,
                  consultations: consultations,
                  onNavigate: onNavigate,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Metric {
  const _Metric(
    this.label,
    this.value,
    this.caption,
    this.icon,
    this.accent,
    this.surface,
  );
  final String label, caption;
  final int value;
  final IconData icon;
  final Color accent, surface;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;
  @override
  Widget build(BuildContext context) => Card(
    color: metric.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: metric.accent.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(metric.icon, color: metric.accent, size: 17),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      metric.label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        letterSpacing: .6,
                        color: AdminTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${metric.value}',
                style: const TextStyle(
                  fontSize: 29,
                  height: 1,
                  color: AdminTheme.forest,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                metric.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AdminTheme.muted),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.onNavigate,
    required this.compact,
    required this.userName,
  });
  final ValueChanged<int>? onNavigate;
  final bool compact;
  final String userName;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final narrow = width < 760;
      final bannerHeight = narrow ? 250.0 : 220.0;
      final date = DateTime.now();
      final dateLabel =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      return Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          color: const Color(0xfff4fbf7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffd7e9df)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10003f2d),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: _BannerCurve(),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xff1c8a60), Color(0xff004c37)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: width * .44,
              top: 14,
              child: Icon(
                Icons.pets,
                size: 70,
                color: AdminTheme.emerald.withValues(alpha: .055),
              ),
            ),
            if (!narrow)
              Positioned(
                right: width * .15,
                bottom: -12,
                width: width * .43,
                height: bannerHeight + 24,
                child: Image.asset(
                  'assets/eivet_pets_hero.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            if (!narrow)
              Positioned(right: 28, top: 17, child: const _AwarenessRibbon()),
            Padding(
              padding: EdgeInsets.fromLTRB(
                narrow ? 17 : 27,
                17,
                narrow ? 17 : 27,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 7,
                    children: [
                      _Badge(
                        'CENTRO VETERINARIO',
                        background: AdminTheme.forest,
                        foreground: Colors.white,
                      ),
                      _Badge(
                        dateLabel,
                        background: Colors.white.withValues(alpha: .72),
                        foreground: AdminTheme.muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: narrow ? width - 36 : width * .48,
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 28,
                          height: 1.14,
                          fontWeight: FontWeight.w800,
                          color: AdminTheme.forest,
                        ),
                        children: userName.trim().isEmpty
                            ? const [TextSpan(text: 'Bienvenido de nuevo')]
                            : [
                                const TextSpan(text: 'Bienvenido de nuevo,\n'),
                                TextSpan(
                                  text: userName.trim(),
                                  style: const TextStyle(
                                    color: Color(0xffc99b32),
                                  ),
                                ),
                              ],
                      ),
                    ),
                  ),
                  if (narrow) ...[
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => onNavigate?.call(1),
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 17,
                          ),
                          label: const Text('Agendar cita'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AdminTheme.forest,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => onNavigate?.call(4),
                          icon: const Icon(Icons.add, size: 17),
                          label: const Text('Nueva consulta'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AdminTheme.forest,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!narrow)
              Positioned(
                right: 18,
                bottom: 17,
                child: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => onNavigate?.call(1),
                      icon: const Icon(Icons.calendar_month_outlined, size: 17),
                      label: const Text('Agendar cita'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AdminTheme.forest,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => onNavigate?.call(4),
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Nueva consulta'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AdminTheme.forest,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _BannerCurve extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width * .68, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width * .62, size.height)
    ..cubicTo(
      size.width * .74,
      size.height * .72,
      size.width * .58,
      size.height * .55,
      size.width * .68,
      size.height * .34,
    )
    ..cubicTo(
      size.width * .76,
      size.height * .18,
      size.width * .70,
      size.height * .1,
      size.width * .68,
      0,
    )
    ..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _AwarenessRibbon extends StatelessWidget {
  const _AwarenessRibbon();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(58, 92), painter: _RibbonPainter());
}

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.round;
    final loop = Path()
      ..moveTo(size.width * .43, size.height * .48)
      ..cubicTo(
        size.width * .12,
        size.height * .28,
        size.width * .23,
        size.height * .03,
        size.width * .49,
        size.height * .1,
      )
      ..cubicTo(
        size.width * .76,
        size.height * .17,
        size.width * .71,
        size.height * .35,
        size.width * .47,
        size.height * .53,
      );
    canvas.drawPath(loop, paint);
    final tail = Path()
      ..moveTo(size.width * .46, size.height * .48)
      ..lineTo(size.width * .24, size.height * .94)
      ..lineTo(size.width * .45, size.height * .83)
      ..lineTo(size.width * .59, size.height * .99)
      ..lineTo(size.width * .58, size.height * .49);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {required this.background, required this.foreground});
  final String text;
  final Color background, foreground;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: foreground,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _AppointmentsCard extends StatelessWidget {
  const _AppointmentsCard({
    required this.items,
    required this.pets,
    required this.onNavigate,
  });
  final List<AdminRecord> items;
  final List<AdminPet> pets;
  final ValueChanged<int>? onNavigate;
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 13, 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xffe8f8ef),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: AdminTheme.emerald,
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agenda de Citas del Día',
                      style: TextStyle(
                        fontSize: 15,
                        color: AdminTheme.forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Gestión en tiempo real de turnos y admisiones clínicas',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: AdminTheme.muted),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => onNavigate?.call(1),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Ver agenda'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 33,
                  color: Color(0xffa9c4b7),
                ),
                SizedBox(height: 7),
                Text(
                  'No hay citas para hoy',
                  style: TextStyle(color: AdminTheme.muted, fontSize: 12),
                ),
              ],
            ),
          )
        else ...[
          const _AppointmentHeader(),
          ...items.take(5).map((item) {
            final pet = pets
                .where((candidate) => candidate.id == item.petId)
                .firstOrNull;
            final owner = item.ownerName.isNotEmpty
                ? item.ownerName
                : pet?.ownerName ?? '';
            return _AppointmentRow(
              item: item,
              pet: pet,
              ownerName: owner,
              onOpen: () => onNavigate?.call(1),
            );
          }),
        ],
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            'Mostrando ${items.length > 5 ? 5 : items.length} de ${items.length} citas de hoy',
            style: const TextStyle(fontSize: 10, color: AdminTheme.muted),
          ),
        ),
      ],
    ),
  );
}

class _AppointmentHeader extends StatelessWidget {
  const _AppointmentHeader();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xfff6faf8),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    child: const Row(
      children: [
        SizedBox(width: 56, child: Text('HORA', style: _headerStyle)),
        SizedBox(width: 178, child: Text('MASCOTA', style: _headerStyle)),
        SizedBox(width: 117, child: Text('PROPIETARIO', style: _headerStyle)),
        Expanded(child: Text('TIPO DE CONSULTA', style: _headerStyle)),
        SizedBox(width: 86, child: Text('ESTADO', style: _headerStyle)),
        SizedBox(width: 24),
      ],
    ),
  );
  static const _headerStyle = TextStyle(
    fontSize: 8,
    letterSpacing: .55,
    fontWeight: FontWeight.w800,
    color: AdminTheme.muted,
  );
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({
    required this.item,
    required this.pet,
    required this.ownerName,
    required this.onOpen,
  });
  final AdminRecord item;
  final AdminPet? pet;
  final String ownerName;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final date = item.date;
    final state = item.status.toLowerCase();
    final color = state == 'confirmada' || state == 'en sala'
        ? const Color(0xff078c5a)
        : const Color(0xffb47b06);
    final tint = state == 'confirmada' || state == 'en sala'
        ? const Color(0xffdff6e9)
        : const Color(0xfffff1cc);
    final typeColor = _typeColor(item.title);
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffedf1ef))),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 3, color: typeColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      child: Text(
                        date == null
                            ? '—'
                            : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AdminTheme.forest,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 178,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: const Color(0xffe7f3ec),
                            child: const Icon(
                              Icons.pets,
                              size: 15,
                              color: AdminTheme.emerald,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.petName.isEmpty
                                      ? 'Mascota'
                                      : item.petName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AdminTheme.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  pet?.breed.isNotEmpty == true
                                      ? pet!.breed
                                      : pet?.species ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AdminTheme.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 117,
                      child: Text(
                        ownerName.isEmpty ? '—' : ownerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AdminTheme.ink,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 86,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status.isEmpty ? 'Pendiente' : item.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      child: PopupMenuButton<String>(
                        tooltip: 'Opciones de cita',
                        padding: EdgeInsets.zero,
                        iconSize: 17,
                        onSelected: (_) => onOpen(),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'open',
                            child: Text('Ver agenda'),
                          ),
                        ],
                        child: const Icon(
                          Icons.more_vert,
                          size: 17,
                          color: AdminTheme.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _typeColor(String title) {
  final text = title.toLowerCase();
  if (text.contains('oncol') || text.contains('quimio'))
    return const Color(0xffa86b12);
  if (text.contains('control')) return const Color(0xff1777a5);
  if (text.contains('cirug')) return const Color(0xffad5275);
  if (text.contains('vacun')) return const Color(0xff14845b);
  return const Color(0xff536b7d);
}

class _RightColumn extends StatelessWidget {
  const _RightColumn({
    required this.pets,
    required this.vaccines,
    required this.treatments,
    required this.consultations,
    required this.onNavigate,
  });
  final List<AdminPet> pets;
  final List<AdminRecord> vaccines, treatments, consultations;
  final ValueChanged<int>? onNavigate;
  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final upcoming = <_CareReminder>[
      ...vaccines
          .where(
            (item) =>
                item.date != null &&
                !DateUtils.dateOnly(item.date!).isBefore(today),
          )
          .map((item) => _CareReminder(item, true)),
      ...treatments
          .where(
            (item) =>
                item.date != null &&
                !DateUtils.dateOnly(item.date!).isBefore(today),
          )
          .map((item) => _CareReminder(item, false)),
    ]..sort((a, b) => a.item.date!.compareTo(b.item.date!));
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.vaccines_outlined,
                      color: AdminTheme.emerald,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Vacunas y Tratamientos Próximos',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: AdminTheme.forest,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigate?.call(5),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
                const Text(
                  'Seguimiento de pacientes y recordatorios',
                  style: TextStyle(fontSize: 9.5, color: AdminTheme.muted),
                ),
                const SizedBox(height: 6),
                if (upcoming.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No hay recordatorios próximos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AdminTheme.muted, fontSize: 11),
                    ),
                  )
                else
                  ...upcoming.take(3).map((reminder) {
                    final entry = reminder.item;
                    return _CompactRecord(
                      icon: reminder.vaccine
                          ? Icons.vaccines_outlined
                          : Icons.medical_information_outlined,
                      title: entry.petName.isEmpty
                          ? entry.title
                          : '${entry.petName} · ${entry.title}',
                      subtitle:
                          '${reminder.vaccine ? 'Próxima dosis' : 'Tratamiento'} · ${_formatShortDate(entry.date!)}',
                      onTap: () => onNavigate?.call(5),
                    );
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.groups_2_outlined,
                      color: AdminTheme.emerald,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pacientes Recientes',
                        style: TextStyle(
                          fontSize: 13,
                          color: AdminTheme.forest,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigate?.call(3),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
                if (pets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Todavía no hay pacientes registrados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AdminTheme.muted, fontSize: 11),
                    ),
                  )
                else
                  ...pets.take(3).map((pet) {
                    final lastVisit =
                        consultations
                            .where(
                              (item) =>
                                  item.petId == pet.id && item.date != null,
                            )
                            .toList()
                          ..sort((a, b) => b.date!.compareTo(a.date!));
                    final visitText = lastVisit.isEmpty
                        ? 'Sin consultas registradas'
                        : 'Última consulta · ${_formatShortDate(lastVisit.first.date!)}';
                    return _CompactRecord(
                      icon: Icons.pets_outlined,
                      title: pet.name,
                      subtitle:
                          '${pet.species}${pet.breed.isEmpty ? '' : ' · ${pet.breed}'}  |  $visitText',
                      onTap: () => onNavigate?.call(3),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CareReminder {
  const _CareReminder(this.item, this.vaccine);
  final AdminRecord item;
  final bool vaccine;
}

class _CompactRecord extends StatelessWidget {
  const _CompactRecord({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffedf1ef))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xffe8f8ef),
            child: Icon(icon, size: 16, color: AdminTheme.emerald),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AdminTheme.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: AdminTheme.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 17, color: AdminTheme.muted),
        ],
      ),
    ),
  );
}

String _formatShortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
