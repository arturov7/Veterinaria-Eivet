import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movil/appointment_request.dart';
import '../../models/movil/registro.dart';
import '../../repositories/movil/appointment_repository.dart';
import '../../repositories/movil/pet_care_repository.dart';
import '../../repositories/movil/registro_repository.dart';
import 'appointment_form_screen.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key, required this.pet});
  final Registro pet;

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
    with SingleTickerProviderStateMixin {
  static const _forest = Color(0xFF063D32);
  static const _green = Color(0xFF07966D);
  static const _mint = Color(0xFFE5F5EC);
  late final TabController _tabs;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _vaccines = const [];
  List<Map<String, dynamic>> _treatments = const [];
  List<Map<String, dynamic>> _consultations = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await context.read<PetCareRepository>().fetch(
        petId: widget.pet.id,
      );
      if (!mounted) return;
      setState(() {
        _vaccines = snapshot.vaccines;
        _treatments = snapshot.treatments;
        _consultations = snapshot.consultations;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cargar el expediente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _bookAppointment() async {
    try {
      final pets = await context.read<RegistroRepository>().fetchAll();
      if (!mounted) return;
      final selected = pets.where((pet) => pet.id == widget.pet.id).toList();
      if (selected.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró la mascota seleccionada.'),
          ),
        );
        return;
      }
      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => AppointmentFormScreen(pets: selected),
        ),
      );
      if (changed == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud de cita enviada.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la solicitud de cita.'),
          ),
        );
      }
    }
  }

  Future<void> _openHistory() async {
    _tabs.animateTo(1);
    try {
      final requests = await context.read<AppointmentRepository>().fetchAll();
      if (!mounted) return;
      final appointments = requests
          .where((item) => item.petId == widget.pet.id)
          .map(
            (item) => <String, dynamic>{
              'fecha': item.scheduledAt.toIso8601String(),
              'motivo': item.reason,
              'diagnostico': 'Solicitud de cita · ${item.status}',
            },
          );
      setState(() => _consultations = [..._consultations, ...appointments]);
    } catch (_) {
      // The history tab still shows authorized clinical records already loaded.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Tarjeta de mascota'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh') _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'refresh',
                child: Text('Actualizar expediente'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: FilledButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      children: [
                        _PetHeader(pet: pet),
                        const SizedBox(height: 18),
                        TabBar(
                          controller: _tabs,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelColor: _forest,
                          unselectedLabelColor: const Color(0xFF718078),
                          indicatorColor: _green,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          tabs: const [
                            Tab(text: 'Información'),
                            Tab(text: 'Historial'),
                            Tab(text: 'Vacunas'),
                            Tab(text: 'Tratamientos'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _tabs,
                          builder: (context, _) => _tabContent(_tabs.index),
                        ),
                      ],
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openHistory,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('Ver historial'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _bookAppointment,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Agendar cita'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: _mint,
                        foregroundColor: _forest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabContent(int index) {
    switch (index) {
      case 1:
        return _RecordList(
          title: 'Consultas anteriores',
          icon: Icons.medical_services_outlined,
          rows: _consultations,
          emptyTitle: 'Aún no hay consultas visibles',
          emptyMessage: 'Las consultas autorizadas aparecerán aquí.',
          kind: _RecordKind.consultation,
        );
      case 2:
        return _RecordList(
          title: 'Vacunas',
          icon: Icons.vaccines_outlined,
          rows: _vaccines,
          emptyTitle: 'Sin vacunas registradas',
          emptyMessage:
              'Cuando se registren vacunas, verás aquí sus fechas y próximas dosis.',
          kind: _RecordKind.vaccine,
        );
      case 3:
        return _RecordList(
          title: 'Tratamientos',
          icon: Icons.medication_outlined,
          rows: _treatments,
          emptyTitle: 'Sin tratamientos registrados',
          emptyMessage:
              'Los tratamientos actuales y anteriores aparecerán aquí.',
          kind: _RecordKind.treatment,
        );
      default:
        return _GeneralInfo(pet: widget.pet);
    }
  }
}

class _PetHeader extends StatelessWidget {
  const _PetHeader({required this.pet});
  final Registro pet;

  @override
  Widget build(BuildContext context) {
    final photo = pet.fotografiaUrl?.trim();
    final detail = [
      if (pet.raza.isNotEmpty) pet.raza,
      [
        if (pet.sexo.isNotEmpty) pet.sexo,
        _age(pet.fechaNacimiento),
      ].where((value) => value.isNotEmpty).join(' • '),
    ].where((value) => value.isNotEmpty).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10063D32),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 112,
              height: 122,
              child: photo != null && photo.isNotEmpty
                  ? Image.network(
                      photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
                    )
                  : const _PhotoPlaceholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.titulo,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: _PetDetailScreenState._forest,
                  ),
                ),
                const SizedBox(height: 3),
                if (detail.isNotEmpty)
                  Text(
                    detail.join('\n'),
                    style: const TextStyle(
                      color: Color(0xFF64756D),
                      height: 1.45,
                    ),
                  ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F6EC),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Color(0xFF07966D)),
                      SizedBox(width: 6),
                      Text(
                        'Activo',
                        style: TextStyle(
                          color: Color(0xFF176246),
                          fontWeight: FontWeight.w700,
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
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFE9F4EF),
    child: Icon(Icons.pets_rounded, size: 48, color: Color(0xFF598474)),
  );
}

class _GeneralInfo extends StatelessWidget {
  const _GeneralInfo({required this.pet});
  final Registro pet;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.pets_outlined, 'Especie', _species(pet.especie)),
      (Icons.category_outlined, 'Raza', _value(pet.raza)),
      (Icons.wc_outlined, 'Sexo', _value(pet.sexo)),
      (Icons.calendar_today_outlined, 'Nacimiento', _date(pet.fechaNacimiento)),
      if (pet.peso != null)
        (
          Icons.monitor_weight_outlined,
          'Peso',
          '${pet.peso!.toStringAsFixed(pet.peso! % 1 == 0 ? 0 : 1)} kg',
        ),
    ];
    return _Panel(
      title: 'Datos generales',
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _InfoRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3),
            if (i < rows.length - 1) const Divider(height: 1, indent: 42),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 13),
    child: Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF176246)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF77857F))),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF1E2A25),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

enum _RecordKind { consultation, vaccine, treatment }

class _RecordList extends StatelessWidget {
  const _RecordList({
    required this.title,
    required this.icon,
    required this.rows,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.kind,
  });
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> rows;
  final String emptyTitle;
  final String emptyMessage;
  final _RecordKind kind;

  @override
  Widget build(BuildContext context) => _Panel(
    title: title,
    child: rows.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: const Color(0xFFEAF5EF),
                  child: Icon(icon, color: const Color(0xFF39765F)),
                ),
                const SizedBox(height: 12),
                Text(
                  emptyTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF34483F),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF77857F), height: 1.4),
                ),
              ],
            ),
          )
        : Column(
            children: [
              for (final row in rows) ...[
                _ClinicalItem(row: row, kind: kind),
                if (row != rows.last) const Divider(height: 1),
              ],
            ],
          ),
  );
}

class _ClinicalItem extends StatelessWidget {
  const _ClinicalItem({required this.row, required this.kind});
  final Map<String, dynamic> row;
  final _RecordKind kind;

  @override
  Widget build(BuildContext context) {
    final title = switch (kind) {
      _RecordKind.vaccine => _value(row['nombre']),
      _RecordKind.treatment => _value(row['nombre'] ?? row['tratamiento']),
      _RecordKind.consultation => _value(row['motivo']),
    };
    final date = switch (kind) {
      _RecordKind.vaccine => _dateRaw(row['fecha_aplicacion']),
      _RecordKind.treatment => _dateRaw(row['fecha_inicio'] ?? row['fecha']),
      _RecordKind.consultation => _dateRaw(row['fecha']),
    };
    final detail = switch (kind) {
      _RecordKind.vaccine => 'Próxima dosis: ${_dateRaw(row['proxima_dosis'])}',
      _RecordKind.treatment => [
        _value(row['indicaciones']),
        if (row['fecha_fin'] != null) 'Hasta: ${_dateRaw(row['fecha_fin'])}',
        if (row['estado'] != null) 'Estado: ${_value(row['estado'])}',
      ].where((item) => item.isNotEmpty).join('\n'),
      _RecordKind.consultation => [
        _value(row['diagnostico']),
        _value(row['tratamiento']),
        _value(row['indicaciones']),
      ].where((item) => item.isNotEmpty).join('\n'),
    };
    final icon = switch (kind) {
      _RecordKind.vaccine => Icons.vaccines_outlined,
      _RecordKind.treatment => Icons.medication_outlined,
      _RecordKind.consultation => Icons.medical_services_outlined,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFEAF5EF),
            child: Icon(icon, size: 19, color: const Color(0xFF39765F)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF25352D),
                  ),
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF728078),
                    ),
                  ),
                ],
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail,
                    style: const TextStyle(
                      height: 1.35,
                      color: Color(0xFF53635B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0B063D32),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF17392D),
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

String _value(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? 'Sin registrar' : text;
}

String _species(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return 'Sin registrar';
  if (normalized == 'perro' || normalized == 'canino') return 'Canino';
  if (normalized == 'gato' || normalized == 'felino') return 'Felino';
  return value;
}

String _date(DateTime? value) {
  if (value == null) return 'Sin registrar';
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

String _dateRaw(dynamic value) {
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  return parsed == null ? '' : _date(parsed);
}

String _age(DateTime? birth) {
  if (birth == null) return '';
  final today = DateTime.now();
  var years = today.year - birth.year;
  if (today.month < birth.month ||
      (today.month == birth.month && today.day < birth.day))
    years--;
  if (years < 0) return '';
  return '$years ${years == 1 ? 'año' : 'años'}';
}
