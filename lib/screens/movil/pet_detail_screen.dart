import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movil/registro.dart';
import '../../repositories/movil/pet_care_repository.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key, required this.pet});
  final Registro pet;

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _vaccines = const [];
  List<Map<String, dynamic>> _treatments = const [];
  List<Map<String, dynamic>> _appointments = const [];

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
      final snapshot = await context.read<PetCareRepository>().fetch(
        petId: widget.pet.id,
      );
      if (mounted)
        setState(() {
          _vaccines = snapshot.vaccines;
          _treatments = snapshot.treatments;
          _appointments = snapshot.appointments;
        });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo cargar el seguimiento clínico.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.pet.titulo)),
    body: _loading
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
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.pets)),
                    title: Text(
                      widget.pet.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      [
                        widget.pet.especie,
                        widget.pet.raza,
                        widget.pet.sexo,
                      ].where((value) => value.isNotEmpty).join(' · '),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _Section(
                  'Vacunas',
                  Icons.vaccines_outlined,
                  _vaccines
                      .map(
                        (item) =>
                            '${item['nombre']} — próxima dosis: ${_date(item['proxima_dosis'])}',
                      )
                      .toList(),
                  'No hay vacunas registradas.',
                ),
                _Section(
                  'Tratamientos',
                  Icons.medical_information_outlined,
                  _treatments
                      .map(
                        (item) =>
                            '${item['tratamiento'] ?? 'Sin tratamiento'}\n${item['indicaciones'] ?? 'Sin indicaciones'}\nPróximo control: ${_date(item['proximo_control'])}',
                      )
                      .toList(),
                  'No hay tratamientos autorizados.',
                ),
                _Section(
                  'Citas',
                  Icons.event_note_outlined,
                  _appointments
                      .map(
                        (item) =>
                            '${_date(item['fecha_hora'])} — ${item['motivo']} (${item['estado']})',
                      )
                      .toList(),
                  'No hay citas registradas.',
                ),
              ],
            ),
          ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.icon, this.items, this.empty);
  final String title;
  final IconData icon;
  final List<String> items;
  final String empty;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF006E1C)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(empty)
        else
          ...items.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(item),
              ),
            ),
          ),
      ],
    ),
  );
}

String _date(dynamic raw) {
  final date = DateTime.tryParse(raw?.toString() ?? '');
  if (date == null) return 'Sin fecha';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
