import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointment_request.dart';
import '../models/registro.dart';
import '../repositories/appointment_repository.dart';

class AppointmentFormScreen extends StatefulWidget {
  const AppointmentFormScreen({super.key, required this.pets, this.initial});
  final List<Registro> pets;
  final AppointmentRequest? initial;

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String? _petId;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _petId =
        initial?.petId ?? (widget.pets.isEmpty ? null : widget.pets.first.id);
    _reasonController.text = initial?.reason ?? '';
    if (initial != null) {
      _date = initial.scheduledAt;
      _time = TimeOfDay.fromDateTime(initial.scheduledAt);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected != null) setState(() => _time = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _petId == null) return;
    final pet = widget.pets.firstWhere((item) => item.id == _petId);
    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    setState(() => _busy = true);
    try {
      final request = AppointmentRequest(
        id: widget.initial?.id,
        petId: _petId!,
        petName: pet.titulo,
        scheduledAt: scheduledAt,
        reason: _reasonController.text,
        status: widget.initial == null
            ? 'pendiente'
            : 'reprogramación solicitada',
        createdAt: widget.initial?.createdAt,
      );
      final repository = context.read<AppointmentRepository>();
      if (widget.initial == null) {
        await repository.create(request);
      } else {
        await repository.update(request);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo guardar la solicitud. Inténtalo nuevamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null
              ? 'Solicitar cita'
              : 'Solicitar reprogramación',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const Text(
              'Completa los datos para enviar tu solicitud a Veterinaria EIVET.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _petId,
              decoration: const InputDecoration(
                labelText: 'Mascota',
                prefixIcon: Icon(Icons.pets),
              ),
              items: widget.pets
                  .map(
                    (pet) => DropdownMenuItem(
                      value: pet.id,
                      child: Text(pet.titulo),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _petId = value),
              validator: (value) =>
                  value == null ? 'Selecciona una mascota' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_time.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Motivo de la consulta',
                hintText: 'Describe brevemente el motivo de la cita.',
              ),
              validator: (value) => (value?.trim().length ?? 0) < 5
                  ? 'Describe el motivo con al menos 5 caracteres'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.send_outlined),
              label: Text(
                _busy
                    ? 'Enviando...'
                    : widget.initial == null
                    ? 'Enviar solicitud'
                    : 'Enviar reprogramación',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
