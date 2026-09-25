import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_models.dart';
import '../controllers/admin_controller.dart';
import '../utils/admin_validators.dart';
import '../utils/admin_theme.dart';
import '../widgets/common.dart';
import '../widgets/eivet_hero_banner.dart';

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
      type: 'propietarios',
      title: 'Clientes y propietarios',
      onAdd: () => _ownerDialog(c, a),
      onRefresh: a.load,
      search: (v) => setState(() => q = v),
      loading: a.loading,
      empty: 'No hay clientes ni propietarios registrados.',
      error: a.error,
      rows: rows.map(
        (e) => DataRow(
          cells: [
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.name),
                const SizedBox(width: 8),
                Chip(label: Text(e.isClientAccount ? 'App móvil' : 'Manual')),
              ],
            )),
            DataCell(Text(e.phone)),
            DataCell(Text(e.email)),
            DataCell(Text(e.address)),
            DataCell(e.isClientAccount
                ? const Tooltip(
                    message: 'Esta cuenta se administra en Supabase Auth.',
                    child: Icon(Icons.lock_outline),
                  )
                : _actions(
                    c,
                    () => _ownerDialog(c, a, e),
                    () => _delete(c, a, e.id!, e.name),
                  )),
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
  String? selectedId;
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
    final selected =
        r.where((e) => e.id == selectedId).firstOrNull ??
        (r.isEmpty ? null : r.first);
    return _PetDirectory(
      items: r,
      selected: selected,
      loading: a.loading,
      onSearch: (v) => setState(() => q = v),
      onSelect: (pet) => setState(() => selectedId = pet.id),
      onAdd: () => _petDialog(c, a, widget.owners),
      onEdit: (pet) => _petDialog(c, a, widget.owners, pet),
      onDelete: (pet) => _delete(c, a, pet.id!, pet.name),
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
  String? selectedConsultationId;
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
    if (widget.type == 'citas') {
      return _AppointmentsView(
        items: r,
        loading: a.loading,
        onAdd: () =>
            _recordDialog(c, a, widget.type, widget.pets, widget.owners),
        onEdit: (e) =>
            _recordDialog(c, a, widget.type, widget.pets, widget.owners, e),
        onDelete: (e) => _delete(c, a, e.id!, e.title),
        onFilter: (value) => setState(() => statusFilter = value),
        filter: statusFilter,
        onSearch: (value) => setState(() => q = value),
      );
    }
    if (widget.type == 'consultas') {
      final selected =
          r.where((e) => e.id == selectedConsultationId).firstOrNull ??
          (r.isEmpty ? null : r.first);
      return _ConsultationHistoryView(
        items: r,
        selected: selected,
        loading: a.loading,
        onSearch: (value) => setState(() => q = value),
        onSelect: (record) =>
            setState(() => selectedConsultationId = record.id),
        onAdd: () =>
            _recordDialog(c, a, widget.type, widget.pets, widget.owners),
        onEdit: (record) => _recordDialog(
          c,
          a,
          widget.type,
          widget.pets,
          widget.owners,
          record,
        ),
        onDelete: (record) => _delete(c, a, record.id!, record.title),
      );
    }
    return _Scaffold(
      type: widget.type,
      title: widget.title,
      onAdd: () => _recordDialog(c, a, widget.type, widget.pets, widget.owners),
      search: (v) => setState(() => q = v),
      loading: a.loading,
      empty: 'No hay registros todavía.',
      filter: widget.type == 'citas'
          ? DropdownButton<String>(
              value: statusFilter,
              onChanged: (value) => setState(() => statusFilter = value!),
              items:
                  const [
                        'Todos',
                        'Pendiente',
                        'Confirmada',
                        'Atendida',
                        'Cancelada',
                      ]
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
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

class _PetDirectory extends StatelessWidget {
  const _PetDirectory({
    required this.items,
    required this.selected,
    required this.loading,
    required this.onSearch,
    required this.onSelect,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });
  final List<AdminPet> items;
  final AdminPet? selected;
  final bool loading;
  final ValueChanged<String> onSearch;
  final ValueChanged<AdminPet> onSelect, onEdit, onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EivetHeroBanner(
          kicker: 'Centro Veterinario • Expediente Clínico Digital',
          title: 'Mascotas y Pacientes',
          subtitle:
              'Visualiza, registra y administra los pacientes EIVET y su seguimiento clínico.',
          icon: Icons.pets,
          accent: const Color(0xffefb940),
          actions: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Exportar reporte'),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.pets),
                label: const Text('Registrar mascota'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _PetMetric(
              label: 'ACTIVOS EN TERAPIA',
              value: '${items.length}',
              icon: Icons.monitor_heart_outlined,
              color: const Color(0xffd1fae5),
            ),
            _PetMetric(
              label: 'MONITOREO ONCOLÓGICO',
              value:
                  '${items.where((e) => e.notes.toLowerCase().contains('onco')).length}',
              icon: Icons.medical_services_outlined,
              color: const Color(0xfffff0ca),
            ),
            _PetMetric(
              label: 'VACUNACIÓN PENDIENTE',
              value: '—',
              icon: Icons.vaccines_outlined,
              color: const Color(0xffffe4e4),
            ),
            _PetMetric(
              label: 'PACIENTES REGISTRADOS',
              value: '${items.length}',
              icon: Icons.verified_outlined,
              color: const Color(0xffe2ecff),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText:
                        'Buscar por nombre de mascota, propietario o ficha',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Mostrando ${items.length} pacientes',
                      style: const TextStyle(
                        color: AdminTheme.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _InfoBadge(
                      text: 'Caninos y felinos',
                      background: Color(0xffeff4ff),
                    ),
                    const SizedBox(width: 7),
                    const _InfoBadge(
                      text: 'Todos los estados',
                      background: Color(0xffeff4ff),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth > 900;
            final list = Card(
              child: loading
                  ? const SizedBox(height: 320, child: LoadingWidget())
                  : items.isEmpty
                  ? const SizedBox(
                      height: 300,
                      child: EmptyStateWidget(
                        message: 'No hay mascotas registradas.',
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          color: const Color(0xffeff4ff),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text('MASCOTA', style: _tableHeader),
                              ),
                              Expanded(
                                child: Text('SEXO / EDAD', style: _tableHeader),
                              ),
                              Expanded(
                                child: Text(
                                  'PESO / COLOR',
                                  style: _tableHeader,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('PROPIETARIO', style: _tableHeader),
                              ),
                            ],
                          ),
                        ),
                        ...items.map(
                          (pet) => _PetRow(
                            pet: pet,
                            selected: selected?.id == pet.id,
                            onTap: () => onSelect(pet),
                            onEdit: () => onEdit(pet),
                            onDelete: () => onDelete(pet),
                          ),
                        ),
                      ],
                    ),
            );
            final details = _PetDetails(
              pet: selected,
              onEdit: selected == null ? null : () => onEdit(selected!),
            );
            if (!wide)
              return Column(
                children: [list, const SizedBox(height: 14), details],
              );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: list),
                const SizedBox(width: 18),
                Expanded(flex: 3, child: details),
              ],
            );
          },
        ),
      ],
    ),
  );
}

const _tableHeader = TextStyle(
  fontSize: 9,
  color: AdminTheme.muted,
  fontWeight: FontWeight.w700,
  letterSpacing: .6,
);

class _PetMetric extends StatelessWidget {
  const _PetMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 176,
    height: 94,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: .5,
                      color: AdminTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 15,
                  backgroundColor: color,
                  child: Icon(icon, size: 15, color: AdminTheme.emerald),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                color: AdminTheme.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PetRow extends StatelessWidget {
  const _PetRow({
    required this.pet,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminPet pet;
  final bool selected;
  final VoidCallback onTap, onEdit, onDelete;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xffeafaf1) : Colors.white,
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AdminTheme.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xffe5eeff),
                    child: Icon(
                      pet.species.toLowerCase().contains('gato')
                          ? Icons.cruelty_free
                          : Icons.pets,
                      color: AdminTheme.emerald,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${pet.species} • ${pet.breed}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AdminTheme.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                '${pet.sex}\n${pet.age} años',
                style: const TextStyle(fontSize: 10, height: 1.6),
              ),
            ),
            Expanded(
              child: Text(
                '${pet.weight ?? '—'} kg\n${pet.color}',
                style: const TextStyle(fontSize: 10, height: 1.6),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pet.ownerName.isEmpty ? '—' : pet.ownerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar mascota'),
                      ),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PetDetails extends StatelessWidget {
  const _PetDetails({required this.pet, required this.onEdit});
  final AdminPet? pet;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) {
    final p = pet;
    if (p == null)
      return const Card(
        child: SizedBox(
          height: 240,
          child: EmptyStateWidget(
            message: 'Selecciona una mascota para ver su ficha.',
          ),
        ),
      );
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: AdminTheme.forest,
                child: const Text(
                  'FICHA CLÍNICA RÁPIDA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: .6,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xffeff4ff),
                      child: Icon(
                        Icons.pets,
                        size: 29,
                        color: AdminTheme.emerald,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${p.species} • ${p.breed}',
                            style: const TextStyle(
                              color: AdminTheme.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 7),
                          _InfoBadge(
                            text: p.id ?? 'Paciente EIVET',
                            background: const Color(0xffeff4ff),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0xffeff4ff),
                padding: const EdgeInsets.all(13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PetFact(
                      label: 'PESO ACTUAL',
                      value: '${p.weight ?? '—'} kg',
                    ),
                    _PetFact(label: 'EDAD', value: '${p.age} años'),
                    _PetFact(label: 'SEXO', value: p.sex.isEmpty ? '—' : p.sex),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TUTOR RESPONSABLE', style: _tableHeader),
                    const SizedBox(height: 6),
                    Text(
                      p.ownerName.isEmpty
                          ? 'Propietario no indicado'
                          : p.ownerName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    const Text('NOTAS CLÍNICAS', style: _tableHeader),
                    const SizedBox(height: 6),
                    Text(
                      p.notes.isEmpty
                          ? 'Sin observaciones clínicas registradas.'
                          : p.notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AdminTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_note),
                        label: const Text('Editar ficha'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atenciones Registradas',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Consulta el historial clínico completo desde Consultas e Historial.',
                  style: TextStyle(fontSize: 11, color: AdminTheme.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PetFact extends StatelessWidget {
  const _PetFact({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 8, color: AdminTheme.muted)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _ConsultationHistoryView extends StatelessWidget {
  const _ConsultationHistoryView({
    required this.items,
    required this.selected,
    required this.loading,
    required this.onSearch,
    required this.onSelect,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });
  final List<AdminRecord> items;
  final AdminRecord? selected;
  final bool loading;
  final ValueChanged<String> onSearch;
  final ValueChanged<AdminRecord> onSelect, onEdit, onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EivetHeroBanner(
          kicker: 'Centro Veterinario • Historial Clínico',
          title: selected == null
              ? 'Consultas e Historial Clínico'
              : 'Ficha clínica de ${selected!.petName}',
          subtitle: selected == null
              ? 'Revisa las consultas y fichas médicas de los pacientes EIVET.'
              : selected!.title,
          icon: Icons.medical_information_outlined,
          accent: const Color(0xffd9587a),
          actions: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Nueva consulta'),
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 1050;
            final listPanel = Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Historial de Consultas',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _InfoBadge(
                          text: '${items.length} registros',
                          background: const Color(0xffeff4ff),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: onSearch,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Buscar en el historial',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (loading)
                      const SizedBox(height: 220, child: LoadingWidget())
                    else if (items.isEmpty)
                      const SizedBox(
                        height: 220,
                        child: EmptyStateWidget(
                          message: 'No hay consultas médicas registradas.',
                        ),
                      )
                    else
                      ...items.map(
                        (e) => _ConsultationListItem(
                          record: e,
                          selected: e.id == selected?.id,
                          onTap: () => onSelect(e),
                          onEdit: () => onEdit(e),
                          onDelete: () => onDelete(e),
                        ),
                      ),
                  ],
                ),
              ),
            );
            final detail = selected == null
                ? const Card(
                    child: SizedBox(
                      height: 260,
                      child: EmptyStateWidget(
                        message:
                            'Selecciona una consulta para ver la ficha médica.',
                      ),
                    ),
                  )
                : _ConsultationDetail(
                    record: selected!,
                    onEdit: () => onEdit(selected!),
                    onDelete: () => onDelete(selected!),
                  );
            if (!wide)
              return Column(
                children: [listPanel, const SizedBox(height: 14), detail],
              );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      listPanel,
                      if (selected != null) const _ProtocolCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(flex: 8, child: detail),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _ConsultationListItem extends StatelessWidget {
  const _ConsultationListItem({
    required this.record,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminRecord record;
  final bool selected;
  final VoidCallback onTap, onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final d = record.date;
    return Card(
      color: selected ? const Color(0xffeff4ff) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 15,
                    color: AdminTheme.emerald,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      d == null
                          ? 'Fecha pendiente'
                          : '${d.day} ${_monthShort(d.month)} ${d.year} • ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AdminTheme.muted,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar ficha')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ],
              ),
              Text(
                record.title.isEmpty ? 'Consulta veterinaria' : record.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                record.detail.isEmpty
                    ? 'Sin notas clínicas registradas.'
                    : record.detail,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AdminTheme.muted),
              ),
              const SizedBox(height: 8),
              Text(
                record.ownerName.isEmpty ? 'EIVET' : record.ownerName,
                style: const TextStyle(
                  fontSize: 10,
                  color: AdminTheme.forest,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsultationDetail extends StatelessWidget {
  const _ConsultationDetail({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminRecord record;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FICHA DE CONSULTA MÉDICA',
                      style: TextStyle(
                        color: AdminTheme.emerald,
                        fontSize: 10,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      record.title.isEmpty
                          ? 'Consulta veterinaria'
                          : record.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Fecha de atención: ${record.date == null ? 'No indicada' : '${record.date!.day}/${record.date!.month}/${record.date!.year}'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AdminTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const _InfoBadge(
                text: 'Ficha EIVET',
                background: Color(0xffdcfce7),
                foreground: AdminTheme.emerald,
              ),
            ],
          ),
          const Divider(height: 26),
          const _ClinicalSectionTitle(
            icon: Icons.help_outline,
            title: 'Motivo de Consulta y Anamnesis',
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffeff4ff),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              record.detail.isEmpty
                  ? 'No se añadieron notas clínicas para esta consulta.'
                  : record.detail,
              style: const TextStyle(fontSize: 13, height: 1.55),
            ),
          ),
          const SizedBox(height: 18),
          const _ClinicalSectionTitle(
            icon: Icons.monitor_heart_outlined,
            title: 'Constantes Vitales y Triaje',
          ),
          const SizedBox(height: 8),
          const Text(
            'No hay constantes vitales asociadas a este registro.',
            style: TextStyle(fontSize: 11, color: AdminTheme.muted),
          ),
          const SizedBox(height: 17),
          const _ClinicalSectionTitle(
            icon: Icons.health_and_safety_outlined,
            title: 'Exploración Física y Hallazgos',
          ),
          const SizedBox(height: 8),
          Text(
            record.detail.isEmpty
                ? 'Sin hallazgos registrados.'
                : record.detail,
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 17),
          const _ClinicalSectionTitle(
            icon: Icons.medical_information_outlined,
            title: 'Diagnóstico Clínico Específico',
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffeff4ff),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              record.title.isEmpty ? 'Diagnóstico no indicado.' : record.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Actualizar Ficha Médica'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ClinicalSectionTitle extends StatelessWidget {
  const _ClinicalSectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 17, color: AdminTheme.emerald),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard();
  @override
  Widget build(BuildContext context) => Card(
    color: AdminTheme.forest,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xff93f3bb)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen Clínico',
                  style: TextStyle(
                    color: Color(0xff93f3bb),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Revisa protocolos y tratamientos desde Vacunas y Tratamientos.',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String _monthShort(int month) => const [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
][month - 1];

class _AppointmentsView extends StatelessWidget {
  const _AppointmentsView({
    required this.items,
    required this.loading,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onFilter,
    required this.filter,
    required this.onSearch,
  });
  final List<AdminRecord> items;
  final bool loading;
  final VoidCallback onAdd;
  final ValueChanged<AdminRecord> onEdit, onDelete;
  final ValueChanged<String> onFilter, onSearch;
  final String filter;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth >= 1050;
      final pending = items
          .where((e) => e.status.toLowerCase() == 'pendiente')
          .toList();
      final confirmed = items
          .where((e) => e.status.toLowerCase() == 'confirmada')
          .length;
      final attended = items
          .where((e) => e.status.toLowerCase() == 'atendida')
          .length;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EivetHeroBanner(
              kicker: 'Gestión de Citas • EIVET',
              title: 'Agenda veterinaria',
              subtitle:
                  'Organiza y da seguimiento a las citas de los pacientes con atención especializada.',
              icon: Icons.calendar_month,
              accent: const Color(0xffe9b54e),
              actions: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Agendar cita'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 9,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusFilter(
                          label: 'Todas',
                          value: 'Todos',
                          current: filter,
                          onSelect: onFilter,
                          count: items.length,
                        ),
                        _StatusFilter(
                          label: 'Pendientes',
                          value: 'Pendiente',
                          current: filter,
                          onSelect: onFilter,
                          count: pending.length,
                        ),
                        _StatusFilter(
                          label: 'Confirmadas',
                          value: 'Confirmada',
                          current: filter,
                          onSelect: onFilter,
                          count: confirmed,
                        ),
                        _StatusFilter(
                          label: 'Atendidas',
                          value: 'Atendida',
                          current: filter,
                          onSelect: onFilter,
                          count: attended,
                        ),
                        _StatusFilter(
                          label: 'Canceladas',
                          value: 'Cancelada',
                          current: filter,
                          onSelect: onFilter,
                          count: items
                              .where(
                                (e) => e.status.toLowerCase() == 'cancelada',
                              )
                              .length,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chevron_left),
                        ),
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: AdminTheme.emerald,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _todayLabel(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chevron_right),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: wide ? 320 : 220,
                          child: TextField(
                            onChanged: onSearch,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Buscar paciente o propietario',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (loading)
              const SizedBox(height: 280, child: LoadingWidget())
            else if (items.isEmpty)
              Card(
                child: SizedBox(
                  height: 240,
                  child: EmptyStateWidget(
                    message: filter == 'Todos'
                        ? 'No hay citas registradas. Usa “Nueva Cita” para agregar un turno.'
                        : 'No hay citas con estado “$filter”.',
                  ),
                ),
              )
            else if (!wide)
              ...items.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AppointmentCard(
                    item: e,
                    onEdit: () => onEdit(e),
                    onDelete: () => onDelete(e),
                  ),
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: items
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _AppointmentCard(
                                item: e,
                                onEdit: () => onEdit(e),
                                onDelete: () => onDelete(e),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Card(
                          color: AdminTheme.forest,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.phone_android,
                                      color: Color(0xff93f3bb),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Sincronización App',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${pending.length} citas pendientes de aprobación',
                                  style: const TextStyle(
                                    color: Color(0xffd2eee0),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...pending
                                    .take(3)
                                    .map(
                                      (e) => Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(11),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: .08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.petName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              e.ownerName,
                                              style: const TextStyle(
                                                color: Color(0xffb5d1c4),
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              e.title,
                                              style: const TextStyle(
                                                color: Color(0xffffdf99),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Salas y Disponibilidad',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const _AvailabilityRow(
                                  room: 'Consultorio 1 (Oncología)',
                                  doctor: 'Dr. Carlos Mendoza',
                                  status: 'En consulta',
                                  color: Color(0xffdc2626),
                                ),
                                const _AvailabilityRow(
                                  room: 'Consultorio 2 (General)',
                                  doctor: 'Dra. Andrea Silva',
                                  status: 'Disponible',
                                  color: AdminTheme.emerald,
                                ),
                                const _AvailabilityRow(
                                  room: 'Quirófano Menor',
                                  doctor: 'Preparación',
                                  status: 'En espera',
                                  color: Color(0xffc29b38),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _AvailabilityRow extends StatelessWidget {
  const _AvailabilityRow({
    required this.room,
    required this.doctor,
    required this.status,
    required this.color,
  });
  final String room, doctor, status;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xffeff4ff),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                doctor,
                style: const TextStyle(fontSize: 10, color: AdminTheme.muted),
              ),
            ],
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({
    required this.label,
    required this.value,
    required this.current,
    required this.onSelect,
    required this.count,
  });
  final String label, value, current;
  final ValueChanged<String> onSelect;
  final int count;
  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return TextButton(
      onPressed: () => onSelect(value),
      style: TextButton.styleFrom(
        backgroundColor: selected ? AdminTheme.forest : const Color(0xffeff4ff),
        foregroundColor: selected ? Colors.white : AdminTheme.ink,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text('$label  $count'),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminRecord item;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final color = switch (item.status.toLowerCase()) {
      'confirmada' => AdminTheme.emerald,
      'atendida' => const Color(0xff9acbb7),
      'cancelada' => const Color(0xffc62828),
      _ => const Color(0xffdfb83f),
    };
    final date = item.date;
    final time = date == null
        ? '--:--'
        : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final end = date == null
        ? ''
        : '${date.add(const Duration(minutes: 45)).hour.toString().padLeft(2, '0')}:${date.add(const Duration(minutes: 45)).minute.toString().padLeft(2, '0')}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 68,
          child: Column(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AdminTheme.forest,
                ),
              ),
              Text(
                end,
                style: const TextStyle(fontSize: 11, color: AdminTheme.muted),
              ),
            ],
          ),
        ),
        Expanded(
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xffeff4ff),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: AdminTheme.emerald,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 7,
                              runSpacing: 5,
                              children: [
                                Text(
                                  item.petName.isEmpty
                                      ? 'Mascota'
                                      : item.petName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                _InfoBadge(
                                  text: item.title.isEmpty
                                      ? 'Consulta general'
                                      : item.title,
                                  background: const Color(0xffeff4ff),
                                ),
                                _InfoBadge(
                                  text: item.status.isEmpty
                                      ? 'Pendiente'
                                      : item.status,
                                  background: color.withValues(alpha: .16),
                                  foreground: color,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${item.ownerName.isEmpty ? 'Propietario sin indicar' : item.ownerName}  •  ${date == null ? 'Fecha por asignar' : '${date.day}/${date.month}/${date.year}'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AdminTheme.muted,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.detail.isEmpty
                                  ? 'Atención veterinaria EIVET'
                                  : item.detail,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar cita'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: const Color(0xffeff4ff),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_note,
                        size: 16,
                        color: AdminTheme.emerald,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          item.status.toLowerCase() == 'pendiente'
                              ? 'Solicitud de cita pendiente de confirmación'
                              : 'Turno veterinario • Atención EIVET',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_calendar_outlined,
                          size: 15,
                        ),
                        label: const Text('Reprogramar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.text,
    required this.background,
    this.foreground = AdminTheme.ink,
  });
  final String text;
  final Color background, foreground;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: foreground,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

String _todayLabel() {
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  final date = DateTime.now();
  return 'Hoy, ${date.day} de ${months[date.month - 1]} de ${date.year}';
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({
    required this.title,
    required this.onAdd,
    required this.search,
    required this.loading,
    required this.empty,
    required this.rows,
    required this.type,
    this.filter,
    this.error,
    this.onRefresh,
  });
  final String title, empty;
  final String type;
  final VoidCallback onAdd;
  final ValueChanged<String> search;
  final bool loading;
  final Iterable<DataRow> rows;
  final Widget? filter;
  final String? error;
  final VoidCallback? onRefresh;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.all(22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EivetHeroBanner(
          kicker: type == 'propietarios'
              ? 'Centro Veterinario • Familias EIVET'
              : 'Centro Veterinario • Gestión clínica',
          title: title,
          subtitle: type == 'propietarios'
              ? 'Cuentas de la app móvil y propietarios registrados manualmente.'
              : 'Administra los registros clínicos y el seguimiento de tus pacientes.',
          icon: type == 'propietarios'
              ? Icons.groups_2_outlined
              : Icons.medical_services_outlined,
          actions: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(
              type == 'propietarios' ? 'Crear cuenta de propietario' : 'Nuevo registro',
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (error != null) ...[
          Text(error!, style: TextStyle(color: Theme.of(c).colorScheme.error)),
          const SizedBox(height: 12),
        ],
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
            if (onRefresh != null)
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar listado',
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
                    columns: type == 'propietarios'
                        ? const [
                            DataColumn(label: Text('Nombre / origen')),
                            DataColumn(label: Text('Teléfono')),
                            DataColumn(label: Text('Correo')),
                            DataColumn(label: Text('Dirección')),
                            DataColumn(label: Text('Acciones')),
                          ]
                        : [
                      DataColumn(
                        label: Text(
                          type == 'mascotas' ? 'MASCOTA' : 'MASCOTA / NOMBRE',
                        ),
                      ),
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
      ad = TextEditingController(text: x?.address),
      password = TextEditingController();
  bool saving = false;
  String? saveError;
  await showDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
      title: Text(x == null ? 'Crear cuenta de propietario' : 'Editar propietario manual'),
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
              if (x != null)
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
                keyboardType: TextInputType.emailAddress,
                validator: (v) => x == null && (v == null || v.trim().isEmpty)
                    ? 'Ingresa el correo de acceso'
                    : v == null || v.trim().isEmpty ? null : AdminValidators.email(v),
              ),
              TextFormField(
                controller: ad,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              if (x == null) ...[
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña de acceso móvil'),
                  validator: (v) => v == null || v.length < 8
                      ? 'Usa al menos 8 caracteres'
                      : null,
                ),
                const SizedBox(height: 12),
                const Text('Esta cuenta podrá iniciar sesión en la app móvil y registrar sus mascotas y citas.'),
              ],
              if (saveError != null) ...[
                const SizedBox(height: 12),
                Text(saveError!, style: TextStyle(color: Theme.of(d).colorScheme.error)),
              ],
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
          onPressed: saving ? null : () async {
            if (f.currentState!.validate()) {
              set(() { saving = true; saveError = null; });
              try {
                final owner = Owner(
                  id: x?.id,
                  name: n.text,
                  ci: ci.text,
                  phone: p.text,
                  email: e.text,
                  address: ad.text,
                );
                if (x == null) {
                  await a.createClientAccount(owner, password.text);
                } else {
                  await a.save(owner);
                }
                if (d.mounted) Navigator.pop(d);
              } catch (error) {
                if (d.mounted) set(() => saveError = '$error');
              } finally {
                if (d.mounted) set(() => saving = false);
              }
            }
          },
          child: Text(saving ? 'Guardando...' : x == null ? 'Crear cuenta' : 'Guardar'),
        ),
      ],
    ),
    ),
  );
}

Future<void> _petDialog(
  BuildContext c,
  PetsController a,
  List<Owner> owners, [
  AdminPet? x,
]) async {
  if (owners.isEmpty && x == null) {
    ScaffoldMessenger.of(c).showSnackBar(
      const SnackBar(content: Text('Registra primero un cliente o propietario.')),
    );
    return;
  }
  final f = GlobalKey<FormState>(),
      n = TextEditingController(text: x?.name),
      sp = TextEditingController(text: x?.species),
      br = TextEditingController(text: x?.breed),
      se = TextEditingController(text: x?.sex),
      w = TextEditingController(text: x?.weight?.toString());
  String owner = x?.ownerId ?? owners.firstOrNull?.id ?? '';
  bool saving = false;
  String? saveError;
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
                if (x?.clientId != null)
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Cliente de la app móvil',
                    ),
                    child: Text(
                      x!.ownerName.isEmpty
                          ? 'Cuenta móvil vinculada'
                          : x.ownerName,
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: owner.isEmpty ? null : owner,
                    items: owners
                        .map((o) => DropdownMenuItem(
                              value: o.id!,
                              child: Text('${o.name} · ${o.isClientAccount ? 'App móvil' : 'Manual'}${o.isClientAccount && o.email.isNotEmpty ? ' (${o.email})' : ''}'),
                            ))
                        .toList(),
                    onChanged: (v) => set(() => owner = v ?? ''),
                    decoration: const InputDecoration(labelText: 'Cliente o propietario'),
                    validator: (v) => v == null ? 'Selecciona un cliente o propietario' : null,
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
                if (saveError != null) ...[
                  const SizedBox(height: 12),
                  Text(saveError!, style: TextStyle(color: Theme.of(d).colorScheme.error)),
                ],
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
            onPressed: saving ? null : () async {
              if (f.currentState!.validate()) {
                final selected = owners.where((o) => o.id == owner).firstOrNull;
                final clientId = x?.clientId ??
                    (selected?.isClientAccount == true ? selected!.id : null);
                set(() { saving = true; saveError = null; });
                try {
                  await a.save(
                    AdminPet(
                      id: x?.id,
                      ownerId: clientId == null ? owner : '',
                      clientId: clientId,
                      name: n.text,
                      species: sp.text,
                      breed: br.text,
                      sex: se.text,
                      weight: double.tryParse(w.text),
                    ),
                  );
                  if (d.mounted) Navigator.pop(d);
                } catch (error) {
                  if (d.mounted) set(() => saveError = 'No se pudo guardar: $error');
                } finally {
                  if (d.mounted) set(() => saving = false);
                }
              }
            },
            child: Text(saving ? 'Guardando...' : 'Guardar'),
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
  DateTime? appliedDate = x?.appliedDate;
  DateTime? nextDoseDate = x?.date;
  DateTime appointmentAt = x?.date ?? DateTime.now().add(const Duration(days: 1));
  bool saving = false;
  String? saveError;
  String pet = x?.petId ?? pets.first.id!,
      status = x?.status ?? (type == 'citas' ? 'Pendiente' : 'Activo');
  await showDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        icon: Icon(
          type == 'vacunas'
              ? Icons.vaccines_outlined
              : type == 'citas' ? Icons.event_available_outlined : Icons.medical_services_outlined,
          color: AdminTheme.emerald,
        ),
        title: Text(
          type == 'vacunas'
              ? (x == null ? 'Registrar vacuna' : 'Editar vacuna')
              : type == 'citas'
              ? (x == null ? 'Agendar cita' : 'Editar cita')
              : type == 'tratamientos'
              ? (x == null ? 'Registrar tratamiento' : 'Editar tratamiento')
              : (x == null ? 'Nuevo registro' : 'Editar registro'),
        ),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
          child: Form(
            key: f,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == 'vacunas') ...[
                  const Text('Datos de vacunación', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Selecciona la mascota y registra la aplicación y su siguiente dosis.'),
                  const SizedBox(height: 16),
                ],
                if (type == 'citas') ...[
                  const Text('Datos de la cita', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Elige una mascota vinculada a un cliente para verla también en la app móvil.'),
                  const SizedBox(height: 16),
                ],
                if (type == 'tratamientos') ...[
                  const Text('Tratamiento para la mascota',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Aparecerá en Cuidados → Tratamientos. Para registrar una vacuna, usa la pestaña Vacunas.'),
                  const SizedBox(height: 16),
                ],
                DropdownButtonFormField(
                  initialValue: pet,
                  items: pets
                      .map(
                        (p) =>
                            DropdownMenuItem(
                              value: p.id!,
                              child: Text(
                                p.clientId == null
                                    ? '${p.name} · ${p.ownerName.isEmpty ? 'sin cuenta móvil' : p.ownerName}'
                                    : '${p.name} · cliente ${p.clientId!.substring(0, 8)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                        : type == 'vacunas' ? 'Nombre de la vacuna' : 'Nombre',
                    prefixIcon: type == 'vacunas' ? const Icon(Icons.vaccines_outlined) : null,
                  ),
                  validator: (v) => AdminValidators.required(v),
                ),
                if (type == 'vacunas') ...[
                  const SizedBox(height: 12),
                  _VaccineDateField(
                    label: 'Fecha de aplicación',
                    value: appliedDate,
                    onChanged: (value) => set(() => appliedDate = value),
                  ),
                  const SizedBox(height: 10),
                  _VaccineDateField(
                    label: 'Próxima dosis',
                    value: nextDoseDate,
                    onChanged: (value) => set(() => nextDoseDate = value),
                    allowClear: true,
                  ),
                ],
                if (type == 'citas') ...[
                  const SizedBox(height: 12),
                  _VaccineDateField(
                    label: 'Fecha de la cita',
                    value: appointmentAt,
                    onChanged: (value) {
                      if (value != null) {
                        set(() => appointmentAt = DateTime(
                          value.year, value.month, value.day,
                          appointmentAt.hour, appointmentAt.minute,
                        ));
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final selected = await showTimePicker(
                        context: d,
                        initialTime: TimeOfDay.fromDateTime(appointmentAt),
                      );
                      if (selected != null) {
                        set(() => appointmentAt = DateTime(
                          appointmentAt.year, appointmentAt.month,
                          appointmentAt.day, selected.hour, selected.minute,
                        ));
                      }
                    },
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text('Hora: ${appointmentAt.hour.toString().padLeft(2, '0')}:${appointmentAt.minute.toString().padLeft(2, '0')}'),
                  ),
                ],
                TextFormField(
                  controller: de,
                  maxLines: type == 'vacunas' ? 4 : 3,
                  decoration: InputDecoration(
                    labelText: type == 'vacunas' ? 'Indicaciones y observaciones' : 'Indicaciones / observaciones',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes_outlined),
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
                              : type == 'vacunas'
                              ? ['Pendiente', 'Aplicada', 'Completa', 'Vencida']
                              : ['Activo', 'Finalizado'])
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (v) => set(() => status = v!),
                  decoration: InputDecoration(labelText: type == 'vacunas'
                      ? 'Estado de la vacuna' : 'Estado'),
                ),
                if (saveError != null) ...[
                  const SizedBox(height: 12),
                  Text(saveError!, style: TextStyle(color: Theme.of(d).colorScheme.error)),
                ],
              ],
            ),
          ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancelar'),
          ),
          FilledButton(
          onPressed: saving ? null : () async {
              if (f.currentState!.validate()) {
                final p = pets.firstWhere((e) => e.id == pet);
                if (type == 'citas' && appointmentAt.isBefore(DateTime.now()) &&
                    (x?.date == null || !appointmentAt.isAtSameMomentAs(x!.date!))) {
                  set(() => saveError = 'Selecciona una fecha y hora futuras.');
                  return;
                }
                set(() { saving = true; saveError = null; });
                try {
                  await a.save(
                    AdminRecord(
                      id: x?.id,
                      petId: pet,
                      ownerId: p.ownerId,
                      clientId: p.clientId,
                      title: t.text.trim(),
                      detail: de.text.trim(),
                      status: status,
                      date: type == 'vacunas'
                          ? nextDoseDate
                          : type == 'citas' ? appointmentAt : DateTime.now(),
                      appliedDate: type == 'vacunas' ? appliedDate : null,
                    ),
                  );
                  if (d.mounted) Navigator.pop(d);
                  if (c.mounted) {
                    ScaffoldMessenger.of(c).showSnackBar(
                      SnackBar(content: Text(
                        p.clientId == null && (type == 'vacunas' || type == 'citas')
                            ? 'Registro guardado. Esta mascota no está vinculada a una cuenta móvil.'
                            : type == 'vacunas'
                                ? 'Vacuna guardada para ${p.name}.'
                                : 'Registro guardado.',
                      )),
                    );
                  }
                } catch (error) {
                  if (d.mounted) {
                    set(() => saveError = 'No se pudo guardar: $error');
                  }
                } finally {
                  if (d.mounted) set(() => saving = false);
                }
              }
            },
            child: Text(saving ? 'Guardando...' : 'Guardar'),
          ),
        ],
      ),
    ),
  );
}

class _VaccineDateField extends StatelessWidget {
  const _VaccineDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    final dateText = value == null
        ? 'Seleccionar fecha'
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_month_outlined),
        suffixIcon: allowClear && value != null
            ? IconButton(
                tooltip: 'Quitar fecha',
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close),
              )
            : null,
      ),
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final selected = await showDatePicker(
            context: context,
            initialDate: value ?? now,
            firstDate: DateTime(now.year - 20),
            lastDate: DateTime(now.year + 30),
          );
          if (selected != null) onChanged(selected);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(dateText),
        ),
      ),
    );
  }
}
