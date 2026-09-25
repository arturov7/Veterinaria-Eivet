import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movil/registro.dart';
import '../../repositories/movil/registro_repository.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key, this.initial});
  final Registro? initial;

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _species;
  late final TextEditingController _breed;
  late final TextEditingController _photo;
  String _sex = '';
  DateTime? _birthDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final pet = widget.initial;
    _name = TextEditingController(text: pet?.titulo ?? '');
    _species = TextEditingController(text: pet?.especie ?? '');
    _breed = TextEditingController(text: pet?.raza ?? '');
    _photo = TextEditingController(text: pet?.fotografiaUrl ?? '');
    _sex = _normalizedSex(pet?.sexo);
    _birthDate = pet?.fechaNacimiento;
  }

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _breed.dispose();
    _photo.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _birthDate = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final pet = Registro(
      id: widget.initial?.id,
      titulo: _name.text,
      especie: _species.text,
      raza: _breed.text,
      sexo: _sex,
      fechaNacimiento: _birthDate,
      fotografiaUrl: _photo.text,
    );
    try {
      final repository = context.read<RegistroRepository>();
      if (widget.initial == null) {
        await repository.create(pet);
      } else {
        await repository.update(pet);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la mascota.')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.initial == null ? 'Registrar mascota' : 'Editar mascota',
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nombre *',
              prefixIcon: Icon(Icons.pets_outlined),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Ingresa el nombre.'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _species,
            decoration: const InputDecoration(
              labelText: 'Especie',
              hintText: 'Perro, gato, etc.',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _breed,
            decoration: const InputDecoration(labelText: 'Raza'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _sex.isEmpty ? null : _sex,
            decoration: const InputDecoration(labelText: 'Sexo'),
            items: const [
              DropdownMenuItem(value: 'Macho', child: Text('Macho')),
              DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
            ],
            onChanged: (value) => setState(() => _sex = value ?? ''),
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_outlined),
            title: const Text('Fecha de nacimiento'),
            subtitle: Text(
              _birthDate == null
                  ? 'Sin registrar'
                  : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          TextFormField(
            controller: _photo,
            decoration: const InputDecoration(
              labelText: 'URL de fotografía (opcional)',
              prefixIcon: Icon(Icons.image_outlined),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 26),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Guardar mascota'),
          ),
        ],
      ),
    ),
  );
}

String _normalizedSex(String? raw) {
  switch (raw?.trim().toLowerCase()) {
    case 'macho':
      return 'Macho';
    case 'hembra':
      return 'Hembra';
    default:
      return '';
  }
}
