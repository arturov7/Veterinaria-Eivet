import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_controller.dart';
import '../admin_models.dart';
import '../utils/admin_theme.dart';
import '../widgets/eivet_hero_banner.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, this.onNavigate});
  final ValueChanged<int>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final owners = context.watch<OwnersController>().items;
    final pets = context.watch<PetsController>().items;
    final appointments = context.watch<AppointmentsController>().items;
    final consultations = context.watch<ConsultationsController>().items;
    final vaccines = context.watch<VaccinesController>().items;
    final pending = appointments
        .where((x) => x.status.toLowerCase() == 'pendiente')
        .length;
    final todayAppointments = appointments
        .where(
          (x) => x.date != null && DateUtils.isSameDay(x.date, DateTime.now()),
        )
        .length;
    final upcoming = vaccines
        .where(
          (x) =>
              x.date != null &&
              !x.date!.isBefore(DateTime.now()) &&
              x.date!.isBefore(DateTime.now().add(const Duration(days: 30))),
        )
        .length;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1250
        ? 5
        : width > 1050
        ? 3
        : width > 650
        ? 2
        : 1;
    final metrics = <_Metric>[
      _Metric(
        'Propietarios',
        owners.length,
        Icons.badge_outlined,
        '+ registrados',
        surface: const Color(0xffe8f8ef),
      ),
      _Metric(
        'Mascotas activas',
        pets.length,
        Icons.pets_outlined,
        'Pacientes en ficha',
        surface: const Color(0xffe7f4ff),
      ),
      _Metric(
        'Citas de hoy',
        todayAppointments,
        Icons.calendar_month_outlined,
        '$pending pendientes',
        accent: const Color(0xffc29b38),
        surface: const Color(0xfffff4d9),
      ),
      _Metric(
        'Consultas clínicas',
        consultations.length,
        Icons.medical_services_outlined,
        'Registros en historial',
        surface: const Color(0xffe6f8f5),
      ),
      _Metric(
        'Alertas médicas',
        upcoming,
        Icons.vaccines_outlined,
        upcoming == 0
            ? 'Sin alertas de vacunación'
            : '$upcoming vacunas en 30 días',
        warning: upcoming > 0,
        accent: const Color(0xffd74b63),
        surface: const Color(0xffffedf0),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(onNavigate: onNavigate, compact: compact),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: metrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 142,
                ),
                itemBuilder: (context, i) => _MetricCard(metric: metrics[i]),
              ),
              const SizedBox(height: 20),
              if (compact) ...[
                _AppointmentsCard(items: appointments, onNavigate: onNavigate),
                const SizedBox(height: 16),
                _QuickAccess(
                  onNavigate: onNavigate,
                  pets: pets,
                  vaccines: vaccines,
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _AppointmentsCard(
                        items: appointments,
                        onNavigate: onNavigate,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 4,
                      child: _QuickAccess(
                        onNavigate: onNavigate,
                        pets: pets,
                        vaccines: vaccines,
                      ),
                    ),
                  ],
                ),
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
    this.icon,
    this.caption, {
    this.accent = AdminTheme.emerald,
    this.warning = false,
    this.surface = Colors.white,
  });
  final String label, caption;
  final int value;
  final IconData icon;
  final Color accent;
  final bool warning;
  final Color surface;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;
  @override
  Widget build(BuildContext context) => Card(
    color: metric.surface,
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: .8,
                    color: AdminTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: metric.warning
                      ? const Color(0xfffef3c7)
                      : const Color(0xfff1f5f9),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  metric.icon,
                  color: metric.warning
                      ? const Color(0xffa16207)
                      : metric.accent,
                  size: 18,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${metric.value}',
            style: const TextStyle(
              fontSize: 30,
              height: 1,
              color: AdminTheme.forest,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            metric.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AdminTheme.muted),
          ),
        ],
      ),
    ),
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onNavigate, required this.compact});
  final ValueChanged<int>? onNavigate;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final date =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.tonalIcon(
          onPressed: () => onNavigate?.call(1),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('Agendar cita'),
        ),
        FilledButton.icon(
          onPressed: () => onNavigate?.call(4),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nueva consulta'),
        ),
      ],
    );
    return EivetHeroBanner(
      kicker: 'Centro Veterinario • Supabase conectado • $date',
      title: 'Bienvenido de nuevo, Dr. Carlos Mendoza',
      subtitle:
          'Jornada especializada en oncología y cirugía ambulatoria. Protocolos activos en sala 1 y 3.',
      actions: actions,
      icon: Icons.health_and_safety_outlined,
      compact: compact,
    );
  }
}

class _AppointmentsCard extends StatelessWidget {
  const _AppointmentsCard({required this.items, required this.onNavigate});
  final List<AdminRecord> items;
  final ValueChanged<int>? onNavigate;
  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final rows =
        items
            .where((e) => e.date != null && DateUtils.isSameDay(e.date, today))
            .toList()
          ..sort((a, b) => a.date!.compareTo(b.date!));
    final visible = rows.take(5).toList();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 18, 15, 14),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 10, color: AdminTheme.emerald),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agenda de Citas del Día',
                        style: TextStyle(
                          fontSize: 16,
                          color: AdminTheme.forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Gestión en tiempo real de turnos y admisiones clínicas',
                        style: TextStyle(fontSize: 11, color: AdminTheme.muted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigate?.call(1),
                  child: const Text('Ver agenda'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.all(25),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 34,
                      color: Colors.blueGrey.shade200,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No hay citas para hoy',
                      style: TextStyle(color: AdminTheme.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...visible.map((e) => _AppointmentRow(item: e)),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
            child: Text(
              'Mostrando ${visible.length} de ${rows.length} citas de hoy',
              style: const TextStyle(fontSize: 10, color: AdminTheme.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.item});
  final AdminRecord item;
  @override
  Widget build(BuildContext context) {
    final date = item.date;
    final statusColor = item.status.toLowerCase() == 'confirmada'
        ? const Color(0xff065f46)
        : const Color(0xff92400e);
    final statusBg = item.status.toLowerCase() == 'confirmada'
        ? const Color(0xffdcfce7)
        : const Color(0xfffef3c7);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              date == null
                  ? '--:--'
                  : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AdminTheme.forest,
                fontSize: 13,
              ),
            ),
          ),
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xffe5eeff),
            child: const Icon(Icons.pets, size: 17, color: AdminTheme.emerald),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.petName.isEmpty ? 'Mascota' : item.petName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminTheme.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AdminTheme.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.status.isEmpty ? 'Pendiente' : item.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess({
    required this.onNavigate,
    required this.pets,
    required this.vaccines,
  });
  final ValueChanged<int>? onNavigate;
  final List<AdminPet> pets;
  final List<AdminRecord> vaccines;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.vaccines_outlined, color: AdminTheme.emerald),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'Vacunas y Tratamientos Próximos',
                      style: TextStyle(fontSize: 15, color: AdminTheme.forest, fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(onPressed: () => onNavigate?.call(5), child: const Text('Ver todos')),
                ],
              ),
              const Text('Seguimiento de pacientes y recordatorios', style: TextStyle(fontSize: 11, color: AdminTheme.muted)),
              const SizedBox(height: 10),
              if (vaccines.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No hay vacunas pendientes registradas.', style: TextStyle(color: AdminTheme.muted, fontSize: 12)),
                )
              else
                ...vaccines.take(3).map((v) => _QuickTile(
                  icon: Icons.vaccines_outlined,
                  title: v.petName.isEmpty ? v.title : '${v.petName} • ${v.title}',
                  subtitle: v.date == null ? 'Fecha por confirmar' : 'Próxima dosis: ${v.date!.day}/${v.date!.month}/${v.date!.year}',
                  onTap: () => onNavigate?.call(5),
                )),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups_2_outlined, color: AdminTheme.emerald),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text('Pacientes Recientes', style: TextStyle(fontSize: 15, color: AdminTheme.forest, fontWeight: FontWeight.w700)),
                  ),
                  TextButton(onPressed: () => onNavigate?.call(3), child: const Text('Ver todos')),
                ],
              ),
              if (pets.isEmpty)
                const Text('Todavía no hay pacientes registrados.', style: TextStyle(color: AdminTheme.muted, fontSize: 12))
              else
                ...pets.take(3).map((pet) => _QuickTile(
                  icon: Icons.pets_outlined,
                  title: pet.name,
                  subtitle: '${pet.species} • ${pet.ownerName}',
                  onTap: () => onNavigate?.call(3),
                )),
            ],
          ),
        ),
      ),
    ],
  );
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 9),
    child: Material(
      color: const Color(0xfff8fafc),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xffe5eeff),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AdminTheme.emerald),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AdminTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AdminTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 17,
                color: AdminTheme.muted,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
