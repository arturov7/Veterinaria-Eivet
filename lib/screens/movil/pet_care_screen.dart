import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/movil/pet_care_repository.dart';

class PetCareScreen extends StatefulWidget {
  const PetCareScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PetCareScreen> createState() => _PetCareScreenState();
}

class _PetCareScreenState extends State<PetCareScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _vaccines = const [];
  List<Map<String, dynamic>> _treatments = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await context.read<PetCareRepository>().fetch();
      if (mounted) {
        setState(() {
          _vaccines = snapshot.vaccines;
          _treatments = snapshot.treatments;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = 'No se pudieron cargar los cuidados: $error',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _body();
    if (!widget.embedded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cuidados y seguimiento')),
        body: content,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Row(
            children: [
              const Expanded(child: Text('Cuidados y seguimiento',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800))),
              IconButton(
                onPressed: _load,
                tooltip: 'Actualizar cuidados',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text('Vacunas, tratamientos e indicaciones de EIVET.'),
        ),
        Expanded(child: content),
      ],
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _ReminderCard(vaccines: _vaccines, treatments: _treatments),
          const SizedBox(height: 22),
          const _SectionTitle(
            icon: Icons.vaccines_outlined,
            title: 'Próximas vacunas',
          ),
          const SizedBox(height: 10),
          if (_vaccines.isEmpty)
            const _EmptyMessage(
              message: 'No hay vacunas registradas para tus mascotas.',
            )
          else
            ..._vaccines.map(
              (vaccine) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _VaccineCard(item: vaccine),
              ),
            ),
          const SizedBox(height: 16),
          const _SectionTitle(
            icon: Icons.medical_information_outlined,
            title: 'Tratamientos e indicaciones',
          ),
          const SizedBox(height: 10),
          if (_treatments.isEmpty)
            const _EmptyMessage(
              message: 'No hay tratamientos autorizados para mostrar.',
            )
          else
            ..._treatments.map(
              (treatment) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TreatmentCard(item: treatment),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.vaccines, required this.treatments});

  final List<Map<String, dynamic>> vaccines;
  final List<Map<String, dynamic>> treatments;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final pendingVaccines = vaccines.where((item) {
      final date = DateTime.tryParse(item['proxima_dosis']?.toString() ?? '');
      return date != null && !DateUtils.dateOnly(date).isBefore(today);
    }).length;
    final pendingControls = treatments.where((item) {
      final date = DateTime.tryParse(item['proximo_control']?.toString() ?? '');
      return date != null && !DateUtils.dateOnly(date).isBefore(today);
    }).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F2E9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF06322B),
            child: Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tienes $pendingVaccines vacuna(s) y $pendingControls control(es) próximos. Revisa las indicaciones de tu veterinario.',
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFF006E1C)),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _VaccineCard extends StatelessWidget {
  const _VaccineCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final pet = _petName(item);
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.vaccines_outlined)),
        title: Text(
          item['nombre']?.toString() ?? 'Vacuna',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '$pet\nAplicada: ${_formatDate(item['fecha_aplicacion'])}\nPróxima dosis: ${_formatDate(item['proxima_dosis'])}\nEstado: ${item['estado'] ?? 'Pendiente'}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final treatment = item['tratamiento']?.toString().trim();
    final instructions = item['indicaciones']?.toString().trim();
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.medical_information_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _petName(item),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if ((item['motivo']?.toString().isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              Text('Motivo: ${item['motivo']}'),
            ],
            if (treatment?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                'Tratamiento: $treatment',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            if (instructions?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text('Indicaciones: $instructions'),
            ],
            if (item['fecha_inicio'] != null) ...[
              const SizedBox(height: 8),
              Text('Inicio: ${_formatDate(item['fecha_inicio'])}'),
            ],
            if (item['fecha_fin'] != null) ...[
              const SizedBox(height: 6),
              Text('Fin previsto: ${_formatDate(item['fecha_fin'])}',
                  style: const TextStyle(color: Color(0xFF47745E))),
            ] else if (item['proximo_control'] != null) ...[
              const SizedBox(height: 10),
              Text('Próximo control: ${_formatDate(item['proximo_control'])}',
                  style: const TextStyle(color: Color(0xFF47745E))),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Center(child: Text(message, textAlign: TextAlign.center)),
  );
}

String _petName(Map<String, dynamic> item) {
  final pet = item['mascotas'];
  if (pet is Map) return pet['nombre']?.toString() ?? 'Mascota';
  return 'Mascota';
}

String _formatDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return 'Sin fecha programada';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
