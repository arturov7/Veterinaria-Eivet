import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_models.dart';
import '../controllers/admin_controller.dart';
import '../utils/admin_validators.dart';
import '../widgets/common.dart';

class OwnersScreen extends StatelessWidget {
  const OwnersScreen({super.key});
  @override
  Widget build(BuildContext c) =>
      _OwnerBody(controller: c.watch<OwnersController>());
}

class _OwnerBody extends StatefulWidget {
  const _OwnerBody({required this.controller});
  final OwnersController controller;
  @override
  State<_OwnerBody> createState() => _OwnerBodyState();
}

class _OwnerBodyState extends State<_OwnerBody> {
  String q = '';
  @override
  Widget build(BuildContext c) {
    final a = widget.controller;
    final rows = a.items
        .where(
          (e) => '${e.name} ${e.phone} ${e.email}'.toLowerCase().contains(
            q.toLowerCase(),
          ),
        )
        .toList();
    return _Scaffold(
      title: 'Propietarios',
      onAdd: () => _ownerDialog(c, a),
      search: (v) => setState(() => q = v),
      loading: a.loading,
      empty: 'No hay propietarios registrados.',
      rows: rows.map(
        (e) => DataRow(
          cells: [
            DataCell(Text(e.name)),
            DataCell(Text(e.phone)),
            DataCell(Text(e.email)),
            DataCell(Text(e.address)),
            DataCell(
              _actions(
                c,
                () => _ownerDialog(c, a, e),
                () => _delete(c, a, e.id!, e.name),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});
  @override
  Widget build(BuildContext c) => _PetBody(
    controller: c.watch<PetsController>(),
    owners: c.watch<OwnersController>().items,
  );
}

class _PetBody extends StatefulWidget {
  const _PetBody({required this.controller, required this.owners});
  final PetsController controller;
  final List<Owner> owners;
  @override
  State<_PetBody> createState() => _PetBodyState();
}

class _PetBodyState extends State<_PetBody> {
  String q = '';
  @override
  Widget build(BuildContext c) {
    final a = widget.controller;
    final r = a.items
        .where(
          (e) => '${e.name} ${e.species} ${e.ownerName}'.toLowerCase().contains(
            q.toLowerCase(),
          ),
        )
        .toList();
    return _Scaffold(
      title: 'Mascotas',
      onAdd: () => _petDialog(c, a, widget.owners),
      search: (v) => setState(() => q = v),
      loading: a.loading,
      empty: 'No hay mascotas registradas.',
      rows: r.map(
        (e) => DataRow(
          cells: [
            DataCell(Text(e.name)),
            DataCell(Text(e.species)),
            DataCell(Text(e.breed)),
            DataCell(Text(e.ownerName)),
            DataCell(
              _actions(
                c,
                () => _petDialog(c, a, widget.owners, e),
                () => _delete(c, a, e.id!, e.name),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({
    super.key,
    required this.title,
    required this.type,
    required this.controller,
  });
  final String title, type;
  final AdminController<AdminRecord> controller;
  @override
  Widget build(BuildContext c) => _RecordBody(
    title: title,
    type: type,
    controller: controller,
    pets: c.watch<PetsController>().items,
    owners: c.watch<OwnersController>().items,
  );
}

class _RecordBody extends StatefulWidget {
  const _RecordBody({
    required this.title,
    required this.type,
    required this.controller,
    required this.pets,
    required this.owners,
  });
  final String title, type;
  final AdminController<AdminRecord> controller;
  final List<AdminPet> pets;
  final List<Owner> owners;
  @override
  State<_RecordBody> createState() => _RecordBodyState();
}

class _RecordBodyState extends State<_RecordBody> {
  String q = '';
  String statusFilter = 'Todos';
  @override
  Widget build(BuildContext c) {
    final a = widget.controller;
    final r = a.items
        .where(
          (e) => '${e.title} ${e.petName} ${e.status}'.toLowerCase().contains(
            q.toLowerCase(),
          ),
        )
        .where((e) => statusFilter == 'Todos' || e.status == statusFilter)
        .toList();
    return _Scaffold(
      title: widget.title,
      onAdd: () => _recordDialog(c, a, widget.type, widget.pets, widget.owners),
      search: (v) => setState(() => q = v),
      loading: a.loading,
      empty: 'No hay registros todavía.',
      filter: widget.type == 'citas'
          ? DropdownButton<String>(
              value: statusFilter,
              onChanged: (value) => setState(() => statusFilter = value!),
              items: const ['Todos', 'Pendiente', 'Confirmada', 'Atendida', 'Cancelada']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
            )
          : null,
      rows: r.map(
        (e) => DataRow(
          cells: [
            DataCell(Text(e.petName)),
            DataCell(Text(e.title)),
            DataCell(Text(e.date?.toString().split(' ').first ?? '-')),
            DataCell(Text(e.status)),
            DataCell(
              _actions(
                c,
                () => _recordDialog(
                  c,
                  a,
                  widget.type,
                  widget.pets,
                  widget.owners,
                  e,
                ),
                () => _delete(c, a, e.id!, e.title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({
    required this.title,
    required this.onAdd,
    required this.search,
    required this.loading,
    required this.empty,
    required this.rows,
    this.filter,
  });
  final String title, empty;
  final VoidCallback onAdd;
  final ValueChanged<String> search;
  final bool loading;
  final Iterable<DataRow> rows;
  final Widget? filter;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(c).textTheme.headlineMedium),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar...',
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (filter != null) ...[filter!, const SizedBox(width: 12)],
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: loading
              ? const LoadingWidget()
              : rows.isEmpty
              ? EmptyStateWidget(message: empty)
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Mascota / nombre')),
                      DataColumn(label: Text('Detalle')),
                      DataColumn(label: Text('Fecha')),
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: rows.toList(),
                  ),
                ),
        ),
      ],
    ),
  );
}

Widget _actions(BuildContext c, VoidCallback edit, VoidCallback del) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      onPressed: edit,
      icon: const Icon(Icons.edit_outlined),
      tooltip: 'Editar',
    ),
    IconButton(
      onPressed: del,
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Eliminar',
    ),
  ],
);
Future<void> _delete(
  BuildContext c,
  AdminController a,
  String id,
  String n,
) async {
  if (await confirmDelete(c, n)) await a.remove(id);
}

Future<void> _ownerDialog(
  BuildContext c,
  OwnersController a, [
  Owner? x,
]) async {
  final f = GlobalKey<FormState>(),
      n = TextEditingController(text: x?.name),
      p = TextEditingController(text: x?.phone),
      e = TextEditingController(text: x?.email),
      ci = TextEditingController(text: x?.ci),
      ad = TextEditingController(text: x?.address);
  await showDialog(
    context: c,
    builder: (d) => AlertDialog(
      title: Text(x == null ? 'Nuevo propietario' : 'Editar propietario'),
      content: SingleChildScrollView(
        child: Form(
          key: f,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: n,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) => AdminValidators.required(v, 'El nombre'),
              ),
              TextFormField(
                controller: ci,
                decoration: const InputDecoration(labelText: 'CI'),
              ),
              TextFormField(
                controller: p,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextFormField(
                controller: e,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (v) => v!.isEmpty ? null : AdminValidators.email(v),
              ),
              TextFormField(
                controller: ad,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            if (f.currentState!.validate()) {
              await a.save(
                Owner(
                  id: x?.id,
                  name: n.text,
                  ci: ci.text,
                  phone: p.text,
                  email: e.text,
                  address: ad.text,
                ),
              );
              if (d.mounted) Navigator.pop(d);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

Future<void> _petDialog(
  BuildContext c,
  PetsController a,
  List<Owner> owners, [
  AdminPet? x,
]) async {
  if (owners.isEmpty) {
    ScaffoldMessenger.of(c).showSnackBar(
      const SnackBar(content: Text('Registra primero un propietario.')),
    );
    return;
  }
  final f = GlobalKey<FormState>(),
      n = TextEditingController(text: x?.name),
      sp = TextEditingController(text: x?.species),
      br = TextEditingController(text: x?.breed),
      se = TextEditingController(text: x?.sex),
      w = TextEditingController(text: x?.weight?.toString());
  String owner = x?.ownerId ?? owners.first.id!;
  await showDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: Text(x == null ? 'Nueva mascota' : 'Editar mascota'),
        content: SingleChildScrollView(
          child: Form(
            key: f,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  initialValue: owner,
                  items: owners
                      .map(
                        (o) =>
                            DropdownMenuItem(value: o.id!, child: Text(o.name)),
                      )
                      .toList(),
                  onChanged: (v) => set(() => owner = v!),
                  decoration: const InputDecoration(labelText: 'Propietario'),
                ),
                TextFormField(
                  controller: n,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => AdminValidators.required(v, 'El nombre'),
                ),
                TextFormField(
                  controller: sp,
                  decoration: const InputDecoration(labelText: 'Especie'),
                ),
                TextFormField(
                  controller: br,
                  decoration: const InputDecoration(labelText: 'Raza'),
                ),
                TextFormField(
                  controller: se,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                ),
                TextFormField(
                  controller: w,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (f.currentState!.validate()) {
                await a.save(
                  AdminPet(
                    id: x?.id,
                    ownerId: owner,
                    name: n.text,
                    species: sp.text,
                    breed: br.text,
                    sex: se.text,
                    weight: double.tryParse(w.text),
                  ),
                );
                if (d.mounted) Navigator.pop(d);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _recordDialog(
  BuildContext c,
  AdminController<AdminRecord> a,
  String type,
  List<AdminPet> pets,
  List<Owner> owners, [
  AdminRecord? x,
]) async {
  if (pets.isEmpty) {
    ScaffoldMessenger.of(c).showSnackBar(
      const SnackBar(content: Text('Registra primero una mascota.')),
    );
    return;
  }
  final f = GlobalKey<FormState>(),
      t = TextEditingController(text: x?.title),
      de = TextEditingController(text: x?.detail);
  String pet = x?.petId ?? pets.first.id!,
      status = x?.status ?? (type == 'citas' ? 'Pendiente' : 'Activo');
  await showDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: Text(x == null ? 'Nuevo registro' : 'Editar registro'),
        content: SingleChildScrollView(
          child: Form(
            key: f,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField(
                  initialValue: pet,
                  items: pets
                      .map(
                        (p) =>
                            DropdownMenuItem(value: p.id!, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (v) => set(() => pet = v!),
                  decoration: const InputDecoration(labelText: 'Mascota'),
                ),
                TextFormField(
                  controller: t,
                  decoration: InputDecoration(
                    labelText: type == 'citas' || type == 'consultas'
                        ? 'Motivo'
                        : 'Nombre',
                  ),
                  validator: (v) => AdminValidators.required(v),
                ),
                TextFormField(
                  controller: de,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Indicaciones / observaciones',
                  ),
                ),
                DropdownButtonFormField(
                  initialValue: status,
                  items:
                      (type == 'citas'
                              ? [
                                  'Pendiente',
                                  'Confirmada',
                                  'Atendida',
                                  'Cancelada',
                                ]
                              : ['Activo', 'Finalizado'])
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (v) => set(() => status = v!),
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (f.currentState!.validate()) {
                final p = pets.firstWhere((e) => e.id == pet);
                await a.save(
                  AdminRecord(
                    id: x?.id,
                    petId: pet,
                    ownerId: p.ownerId,
                    title: t.text,
                    detail: de.text,
                    status: status,
                    date: DateTime.now(),
                  ),
                );
                if (d.mounted) Navigator.pop(d);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}
