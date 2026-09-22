import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_controller.dart';
import '../admin_models.dart';
import '../utils/admin_theme.dart';

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
    final upcoming = vaccines
        .where(
          (x) =>
              x.date != null &&
              !x.date!.isBefore(DateTime.now()) &&
              x.date!.isBefore(DateTime.now().add(const Duration(days: 30))),
        )
        .length;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 1450
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
      ),
      _Metric(
        'Mascotas activas',
        pets.length,
        Icons.pets_outlined,
        'Pacientes en ficha',
      ),
      _Metric(
        'Citas pendientes',
        pending,
        Icons.calendar_month_outlined,
        '${appointments.length} solicitudes en total',
        accent: const Color(0xffc29b38),
      ),
      _Metric(
        'Consultas clínicas',
        consultations.length,
        Icons.medical_services_outlined,
        'Registros en historial',
      ),
      _Metric(
        'Vacunas próximas',
        upcoming,
        Icons.vaccines_outlined,
        'En los siguientes 30 días',
        warning: upcoming > 0,
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
                _QuickAccess(onNavigate: onNavigate),
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
                      child: _QuickAccess(onNavigate: onNavigate),
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
  });
  final String label, caption;
  final int value;
  final IconData icon;
  final Color accent;
  final bool warning;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;
  @override
  Widget build(BuildContext context) => Card(
    color: metric.warning ? const Color(0xfffffbeb) : Colors.white,
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
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Tag(
              text: 'CENTRO VETERINARIO',
              color: const Color(0xffdcfce7),
              foreground: const Color(0xff065f46),
            ),
            _Tag(
              text: '● Supabase conectado',
              color: const Color(0xffdcfce7),
              foreground: const Color(0xff065f46),
            ),
            Text(
              date,
              style: const TextStyle(fontSize: 11, color: AdminTheme.muted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Panel de gestión EIVET',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: compact ? 23 : 27),
        ),
        const SizedBox(height: 4),
        const Text(
          'Resumen de la actividad clínica y los registros de tu veterinaria.',
          style: TextStyle(fontSize: 13, color: AdminTheme.muted),
        ),
      ],
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => onNavigate?.call(3),
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 23),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [intro, const SizedBox(height: 16), actions],
              )
            : Row(
                children: [
                  Expanded(child: intro),
                  const SizedBox(width: 20),
                  actions,
                ],
              ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    required this.color,
    required this.foreground,
  });
  final String text;
  final Color color, foreground;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: foreground,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
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
                        'Agenda de citas del día',
                        style: TextStyle(
                          fontSize: 16,
                          color: AdminTheme.forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Solicitudes programadas para hoy',
                        style: TextStyle(fontSize: 11, color: AdminTheme.muted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigate?.call(3),
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
  const _QuickAccess({required this.onNavigate});
  final ValueChanged<int>? onNavigate;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 16,
              color: AdminTheme.forest,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Continúa con las tareas frecuentes',
            style: TextStyle(fontSize: 11, color: AdminTheme.muted),
          ),
          const SizedBox(height: 14),
          _QuickTile(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Registrar propietario',
            subtitle: 'Agregar un nuevo cliente',
            onTap: () => onNavigate?.call(1),
          ),
          _QuickTile(
            icon: Icons.pets_outlined,
            title: 'Registrar mascota',
            subtitle: 'Crear ficha de paciente',
            onTap: () => onNavigate?.call(2),
          ),
          _QuickTile(
            icon: Icons.calendar_month_outlined,
            title: 'Gestionar citas',
            subtitle: 'Revisar solicitudes y estados',
            onTap: () => onNavigate?.call(3),
          ),
          _QuickTile(
            icon: Icons.medical_information_outlined,
            title: 'Historial clínico',
            subtitle: 'Consultas, vacunas y tratamientos',
            onTap: () => onNavigate?.call(4),
          ),
        ],
      ),
    ),
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
