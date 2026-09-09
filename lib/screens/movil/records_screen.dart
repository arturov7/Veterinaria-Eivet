import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movil/registro.dart';
import '../../repositories/movil/registro_repository.dart';
import 'pet_detail_screen.dart';
import 'pet_form_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  bool _loading = true;
  String? _error;
  List<Registro> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await context.read<RegistroRepository>().fetchAll();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudieron cargar las mascotas.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([Registro? pet]) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute<bool>(builder: (_) => PetFormScreen(initial: pet)));
    if (changed == true) await _load();
  }

  Future<void> _delete(Registro pet) async {
    if (pet.id == null) return;
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Eliminar mascota'), content: Text('¿Deseas eliminar a ${pet.titulo}? También se eliminarán sus datos relacionados.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Eliminar'))]));
    if (confirmed != true || !mounted) return;
    try {
      await context.read<RegistroRepository>().delete(pet.id!);
      await _load();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo eliminar la mascota.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _body();
    if (!widget.embedded) return Scaffold(appBar: AppBar(title: const Text('Mis mascotas')), floatingActionButton: _addButton(), body: body);
    return Stack(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 4), child: Text('Mis mascotas', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800))),
        const Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 8), child: Text('Registra y actualiza los datos de tus mascotas.')),
        Expanded(child: body),
      ]),
      Positioned(right: 20, bottom: 18, child: _addButton()),
    ]);
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Reintentar')));
    return RefreshIndicator(onRefresh: _load, child: _items.isEmpty ? ListView(children: const [SizedBox(height: 140), Icon(Icons.pets_outlined, size: 64, color: Color(0xFF537763)), SizedBox(height: 14), Center(child: Text('Aún no registraste mascotas.'))]) : ListView.separated(padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), itemCount: _items.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, index) => _PetCard(pet: _items[index], onOpen: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => PetDetailScreen(pet: _items[index]))), onEdit: () => _openForm(_items[index]), onDelete: () => _delete(_items[index]))));
  }

  Widget _addButton() => FloatingActionButton.extended(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Registrar mascota'));
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onOpen, required this.onEdit, required this.onDelete});
  final Registro pet;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFC5D4C9))),
        child: ListTile(
          onTap: onOpen,
          leading: const CircleAvatar(backgroundColor: Color(0xFFE5F2E9), child: Icon(Icons.pets, color: Color(0xFF003F35))),
          title: Text(pet.titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text([pet.especie, pet.raza, pet.sexo].where((value) => value.isNotEmpty).join(' · ')),
          trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'editar') onEdit(); if (value == 'eliminar') onDelete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'editar', child: Text('Editar')), PopupMenuItem(value: 'eliminar', child: Text('Eliminar'))]),
        ),
      );
}
