import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment_request.dart';
import '../models/registro.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/registro_repository.dart';
import 'appointment_form_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _loading = true;
  String? _error;
  List<AppointmentRequest> _items = const <AppointmentRequest>[];
  List<Registro> _pets = const <Registro>[];
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
      final results = await Future.wait<Object>(<Future<Object>>[
        context.read<AppointmentRepository>().fetchAll(),
        context.read<RegistroRepository>().fetchAll(),
      ]);
      if (mounted)
        setState(() {
          _items = results[0] as List<AppointmentRequest>;
          _pets = results[1] as List<Registro>;
        });
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'No se pudieron cargar las solicitudes. Inténtalo nuevamente.',
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([AppointmentRequest? initial]) async {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay mascotas disponibles para solicitar una cita.'),
        ),
      );
      return;
    }
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => AppointmentFormScreen(pets: _pets, initial: initial),
      ),
    );
    if (changed == true) await _load();
  }

  Future<void> _delete(AppointmentRequest item) async {
    if (item.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar solicitud'),
        content: const Text('¿Deseas cancelar esta solicitud de cita?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancelar solicitud'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<AppointmentRepository>().delete(item.id!);
      await _load();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cancelar la solicitud.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _body();
    if (widget.embedded)
      return Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                  'Solicitudes de citas',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text('Gestiona tus solicitudes enviadas a EIVET.'),
              ),
              Expanded(child: content),
            ],
          ),
          Positioned(right: 20, bottom: 18, child: _addButton()),
        ],
      );
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de citas')),
      floatingActionButton: _addButton(),
      body: content,
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return Center(
        child: FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      );
    return RefreshIndicator(
      onRefresh: _load,
      child: _items.isEmpty
          ? ListView(
              children: const <Widget>[
                SizedBox(height: 140),
                Icon(
                  Icons.calendar_month_outlined,
                  size: 64,
                  color: Color(0xFF537763),
                ),
                SizedBox(height: 14),
                Center(child: Text('Aún no enviaste solicitudes de cita.')),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _AppointmentCard(
                item: _items[index],
                onEdit: () => _openForm(_items[index]),
                onDelete: () => _delete(_items[index]),
              ),
            ),
    );
  }

  Widget _addButton() => FloatingActionButton.extended(
    onPressed: () => _openForm(),
    icon: const Icon(Icons.add),
    label: const Text('Solicitar cita'),
  );
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });
  final AppointmentRequest item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final date = item.scheduledAt;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFC5D4C9)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE5F2E9),
          child: Icon(Icons.calendar_month, color: Color(0xFF003F35)),
        ),
        title: Text(
          item.petName,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}\n${item.reason}\nEstado: ${item.status}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'reprogramar') onEdit();
            if (value == 'cancelar') onDelete();
          },
          itemBuilder: (_) => const <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: 'reprogramar',
              child: Text('Solicitar reprogramación'),
            ),
            PopupMenuItem(value: 'cancelar', child: Text('Cancelar solicitud')),
          ],
        ),
      ),
    );
  }
}
