import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movil/appointment_request.dart';
import '../../models/movil/registro.dart';
import '../../models/movil/veterinary_content.dart';
import '../../repositories/movil/appointment_repository.dart';
import '../../repositories/movil/veterinary_catalog_repository.dart';

class AppointmentFormScreen extends StatefulWidget {
  const AppointmentFormScreen({super.key, required this.pets, this.initial});

  final List<Registro> pets;
  final AppointmentRequest? initial;

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  static const _forest = Color(0xff063b30);
  static const _green = Color(0xff07824f);
  static const _mint = Color(0xffeaf7f0);
  static const _muted = Color(0xff718078);
  static const _slots = <TimeOfDay>[
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
  ];

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  int _step = 0;
  String? _petId;
  String? _serviceTitle;
  DateTime _date = DateUtils.dateOnly(DateTime.now().add(const Duration(days: 1)));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _petId = initial?.petId ?? _firstPetId;
    final today = DateUtils.dateOnly(DateTime.now());
    _date = initial == null || DateUtils.dateOnly(initial.scheduledAt).isBefore(today)
        ? today.add(const Duration(days: 1))
        : DateUtils.dateOnly(initial.scheduledAt);
    if (initial != null) {
      _time = TimeOfDay.fromDateTime(initial.scheduledAt);
      final parts = initial.reason.split('\n');
      if (parts.first.startsWith('Servicio: ')) {
        _serviceTitle = parts.first.substring('Servicio: '.length).trim();
        _reasonController.text = parts.skip(1).join('\n').replaceFirst(RegExp(r'^Motivo: '), '');
      } else {
        _reasonController.text = initial.reason;
      }
    }
  }

  String? get _firstPetId {
    for (final pet in widget.pets) {
      if (pet.id != null && pet.id!.isNotEmpty) return pet.id;
    }
    return null;
  }

  Registro? get _selectedPet {
    for (final pet in widget.pets) {
      if (pet.id == _petId) return pet;
    }
    return null;
  }

  List<VeterinaryService> get _services =>
      context.read<VeterinaryCatalogRepository>().services;

  VeterinaryService? get _selectedService {
    for (final service in _services) {
      if (service.title == _serviceTitle) return service;
    }
    return null;
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
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: _forest),
        ),
        child: child!,
      ),
    );
    if (selected != null) setState(() => _date = DateUtils.dateOnly(selected));
  }

  void _continue() {
    if (_step == 0 && _selectedPet == null) {
      _message('Selecciona una mascota registrada para continuar.');
      return;
    }
    if (_step == 1 && _selectedService == null) {
      _message('Selecciona el servicio veterinario.');
      return;
    }
    if (_step == 2 && _date.isBefore(DateUtils.dateOnly(DateTime.now()))) {
      _message('Selecciona una fecha válida.');
      return;
    }
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.maybePop(context);
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() ||
        _selectedPet == null ||
        _selectedService == null) {
      return;
    }

    final pet = _selectedPet!;
    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final reason = 'Servicio: ${_selectedService!.title}\n'
        'Motivo: ${_reasonController.text.trim()}';

    setState(() => _busy = true);
    try {
      final request = AppointmentRequest(
        id: widget.initial?.id,
        petId: _petId!,
        petName: pet.titulo,
        scheduledAt: scheduledAt,
        reason: reason,
        status: widget.initial == null ? 'Pendiente' : 'Reprogramada',
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
        _message('No se pudo guardar la solicitud. Inténtalo nuevamente.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (_serviceTitle == null && services.isNotEmpty) {
      _serviceTitle = services.first.title;
    }

    return Scaffold(
      backgroundColor: const Color(0xfff8fbf9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: _forest,
        ),
        title: Text(
          widget.initial == null ? 'Solicitar cita' : 'Solicitar reprogramación',
          style: const TextStyle(color: _forest, fontWeight: FontWeight.w800, fontSize: 19),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
            child: _StepProgress(current: _step),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _stepContent(services),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xffe6eee9))),
              boxShadow: [
                BoxShadow(color: Color(0x0c063b30), blurRadius: 12, offset: Offset(0, -3)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _continue,
                  style: FilledButton.styleFrom(
                    backgroundColor: _forest,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    elevation: 2,
                  ),
                  child: _busy
                      ? const SizedBox.square(dimension: 23, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_step == 3 ? (widget.initial == null ? 'Confirmar solicitud' : 'Enviar reprogramación') : 'Continuar'),
                            const SizedBox(width: 9),
                            Icon(_step == 3 ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepContent(List<VeterinaryService> services) {
    return switch (_step) {
      0 => _petStep(key: const ValueKey(0)),
      1 => _serviceStep(services, key: const ValueKey(1)),
      2 => _dateStep(key: const ValueKey(2)),
      _ => _confirmationStep(key: const ValueKey(3)),
    };
  }

  Widget _petStep({required Key key}) => Column(
    key: key,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _StepHeading(
        title: 'Selecciona una mascota',
        subtitle: 'Elige a quién traerás a su próxima consulta.',
      ),
      const SizedBox(height: 18),
      if (widget.pets.isEmpty)
        const _EmptyPets()
      else
        ...widget.pets.map((pet) {
          final selected = pet.id != null && pet.id == _petId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PetChoiceCard(
              pet: pet,
              selected: selected,
              onTap: pet.id == null ? null : () => setState(() => _petId = pet.id),
            ),
          );
        }),
    ],
  );

  Widget _serviceStep(List<VeterinaryService> services, {required Key key}) =>
      Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeading(
            title: '¿Qué servicio necesita?',
            subtitle: 'Selecciona el tipo de atención veterinaria.',
          ),
          const SizedBox(height: 18),
          ...services.map((service) {
            final selected = service.title == _serviceTitle;
            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: _ServiceChoiceCard(
                service: service,
                selected: selected,
                onTap: () => setState(() => _serviceTitle = service.title),
              ),
            );
          }),
        ],
      );

  Widget _dateStep({required Key key}) => Column(
    key: key,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _StepHeading(
        title: 'Elige fecha y hora',
        subtitle: 'Indica cuándo te gustaría visitarnos.',
      ),
      const SizedBox(height: 19),
      const _SectionLabel('FECHA DE LA CITA'),
      const SizedBox(height: 9),
      InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              const _IconTile(icon: Icons.calendar_month_rounded, color: Color(0xffe6f5ed)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_longDate(_date), style: const TextStyle(color: _forest, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    const Text('Toca para cambiar la fecha', style: TextStyle(color: _muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: _green),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
      const _SectionLabel('HORARIOS SUGERIDOS'),
      const SizedBox(height: 9),
      Wrap(
        spacing: 9,
        runSpacing: 9,
        children: _slots.map((slot) {
          final selected = slot.hour == _time.hour && slot.minute == _time.minute;
          return ChoiceChip(
            label: Text(_formatTime(slot)),
            selected: selected,
            onSelected: (_) => setState(() => _time = slot),
            showCheckmark: false,
            selectedColor: _forest,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? _forest : const Color(0xffdce8e1)),
            labelStyle: TextStyle(
              color: selected ? Colors.white : _forest,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          );
        }).toList(),
      ),
      const SizedBox(height: 13),
      Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: const Color(0xfffff7e5), borderRadius: BorderRadius.circular(13)),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xffa97713), size: 19),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'El horario quedará sujeto a confirmación por parte de la clínica.',
                style: TextStyle(color: Color(0xff755a21), fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _confirmationStep({required Key key}) => Column(
    key: key,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _StepHeading(
        title: 'Confirma tu solicitud',
        subtitle: 'Revisa los datos antes de enviarla a la clínica.',
      ),
      const SizedBox(height: 18),
      _SummaryCard(
        pet: _selectedPet,
        service: _selectedService,
        date: _date,
        time: _time,
      ),
      const SizedBox(height: 20),
      const _SectionLabel('MOTIVO DE LA CONSULTA'),
      const SizedBox(height: 8),
      TextFormField(
        controller: _reasonController,
        minLines: 3,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Describe brevemente cómo podemos ayudar.',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xffdce8e1))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xffdce8e1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _green, width: 1.5)),
        ),
        validator: (value) => (value?.trim().length ?? 0) < 5
            ? 'Describe el motivo con al menos 5 caracteres'
            : null,
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _mint, borderRadius: BorderRadius.circular(15)),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: _green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'La cita se enviará como solicitud pendiente. EIVET confirmará la disponibilidad.',
                style: TextStyle(color: _forest, fontSize: 12, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  static BoxDecoration _cardDecoration({bool selected = false}) => BoxDecoration(
    color: selected ? const Color(0xfff2fbf6) : Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: selected ? const Color(0xffb8dfca) : const Color(0xffe8efeb),
      width: selected ? 1.4 : 1,
    ),
    boxShadow: const [
      BoxShadow(color: Color(0x08063b30), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );

  static String _longDate(DateTime date) {
    const weekdays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current});
  final int current;

  static const _labels = ['Mascota', 'Servicio', 'Fecha', 'Confirmar'];

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(_labels.length, (index) {
      final complete = index < current;
      final active = index == current;
      final color = active || complete ? const Color(0xff063b30) : const Color(0xffe8f2ed);
      return Expanded(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: active ? const Color(0xffb6dfc9) : Colors.transparent, width: 3),
                      boxShadow: active
                          ? const [BoxShadow(color: Color(0x18063b30), blurRadius: 7, offset: Offset(0, 2))]
                          : null,
                    ),
                    child: complete
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : Text('${index + 1}', style: TextStyle(color: active ? Colors.white : const Color(0xff87978e), fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? const Color(0xff063b30) : const Color(0xff75837b),
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (index < _labels.length - 1)
              Container(
                height: 2,
                width: 22,
                margin: const EdgeInsets.only(left: 3, right: 3, bottom: 24),
                color: index < current ? const Color(0xff52b98b) : const Color(0xffe6ece8),
              ),
          ],
        ),
      );
    }),
  );
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: Color(0xff15251e), fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
      const SizedBox(height: 5),
      Text(subtitle, style: const TextStyle(color: Color(0xff75837b), fontSize: 13, height: 1.4)),
    ],
  );
}

class _PetChoiceCard extends StatelessWidget {
  const _PetChoiceCard({required this.pet, required this.selected, required this.onTap});
  final Registro pet;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (pet.raza.isNotEmpty) pet.raza,
      if (pet.fechaNacimiento != null) '${_petAge(pet.fechaNacimiento!)} años',
    ];
    if (details.isEmpty && pet.especie.isNotEmpty) details.add(pet.especie);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: _AppointmentFormScreenState._cardDecoration(selected: selected),
          child: Row(
            children: [
              _PetAvatar(pet: pet, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xff1b2d25), fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(details.join(' • ').isEmpty ? 'Mascota registrada' : details.join(' • '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xff77847d), fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 27,
                height: 27,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xff087d55) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? const Color(0xff087d55) : const Color(0xffaab8b0), width: 1.5),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _petAge(DateTime birth) {
    final now = DateTime.now();
    var years = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) years--;
    return years < 0 ? 0 : years;
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.pet, required this.size});
  final Registro pet;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = pet.fotografiaUrl?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xffedf3f0),
        child: url.isEmpty
            ? const Icon(Icons.pets_rounded, color: Color(0xff6f9380), size: 31)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.pets_rounded, color: Color(0xff6f9380), size: 31),
              ),
      ),
    );
  }
}

class _ServiceChoiceCard extends StatelessWidget {
  const _ServiceChoiceCard({required this.service, required this.selected, required this.onTap});
  final VeterinaryService service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(17),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: _AppointmentFormScreenState._cardDecoration(selected: selected),
      child: Row(
        children: [
          _IconTile(icon: service.icon, color: selected ? const Color(0xffd5f0e1) : const Color(0xfff0f5f2)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title, style: const TextStyle(color: Color(0xff183128), fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(service.subtitle, style: const TextStyle(color: Color(0xff78857e), fontSize: 12)),
              ],
            ),
          ),
          Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: selected ? const Color(0xff07824f) : const Color(0xffa9b5ae), size: 23),
        ],
      ),
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.pet, required this.service, required this.date, required this.time});
  final Registro? pet;
  final VeterinaryService? service;
  final DateTime date;
  final TimeOfDay time;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: _AppointmentFormScreenState._cardDecoration(),
    child: Column(
      children: [
        Row(
          children: [
            _PetAvatar(pet: pet!, size: 55),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('MASCOTA'),
                  const SizedBox(height: 4),
                  Text(pet!.titulo, style: const TextStyle(color: Color(0xff183128), fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 25),
        _SummaryLine(icon: service!.icon, label: 'Servicio', value: service!.title),
        const SizedBox(height: 13),
        _SummaryLine(icon: Icons.calendar_month_rounded, label: 'Fecha', value: _AppointmentFormScreenState._longDate(date)),
        const SizedBox(height: 13),
        _SummaryLine(icon: Icons.schedule_rounded, label: 'Hora', value: _AppointmentFormScreenState._formatTime(time)),
      ],
    ),
  );
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 19, color: const Color(0xff07824f)),
      const SizedBox(width: 10),
      SizedBox(width: 64, child: Text(label, style: const TextStyle(color: Color(0xff78857e), fontSize: 12))),
      Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xff183128), fontSize: 13, fontWeight: FontWeight.w700))),
    ],
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: Color(0xff738279), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8));
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
    child: Icon(icon, color: const Color(0xff087d55), size: 22),
  );
}

class _EmptyPets extends StatelessWidget {
  const _EmptyPets();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: const Column(
      children: [
        Icon(Icons.pets_outlined, color: Color(0xff72917f), size: 36),
        SizedBox(height: 8),
        Text('No hay mascotas registradas', style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 4),
        Text('Registra una mascota antes de solicitar una cita.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff718078), fontSize: 12)),
      ],
    ),
  );
}
