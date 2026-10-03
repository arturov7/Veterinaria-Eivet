import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movil/registro.dart';
import '../../repositories/movil/registro_repository.dart';
import 'pet_detail_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key, this.embedded = false, this.onBack});

  final bool embedded;
  final VoidCallback? onBack;

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  static const _forest = Color(0xff064537);
  static const _emerald = Color(0xff07966d);

  final _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  String _query = '';
  List<Registro> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final items = await context.read<RegistroRepository>().fetchAll();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted)
        setState(() => _error = 'No se pudieron cargar las mascotas.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Registro> get _visibleItems {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items
        .where((pet) {
          final searchable =
              '${pet.titulo} ${pet.especie} ${pet.raza} ${pet.sexo}'
                  .toLowerCase();
          return searchable.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.embedded) {
      return Scaffold(
        backgroundColor: const Color(0xfff4f8f6),
        body: SafeArea(child: _content()),
      );
    }
    return _content();
  }

  Widget _content() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  'Mis mascotas',
                  style: const TextStyle(
                    color: Color(0xff14251f),
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Volver al inicio',
                  onPressed: widget.onBack ?? () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: _forest,
                  iconSize: 21,
                ),
              ),
            ],
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(22, 3, 22, 15),
        child: Text(
          'Consulta las mascotas registradas por el personal de EIVET.',
          style: TextStyle(color: Color(0xff65756f), fontSize: 14),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Buscar mascota...',
            prefixIcon: const Icon(Icons.search_rounded, size: 24),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xffe0e9e5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: _emerald, width: 1.4),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(child: _body()),
    ],
  );

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      );
    }

    final pets = _visibleItems;
    if (pets.isEmpty) {
      final searching = _query.trim().isNotEmpty;
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 56),
            Icon(
              searching ? Icons.search_off_rounded : Icons.pets_outlined,
              size: 58,
              color: const Color(0xff8ba69a),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                searching
                    ? 'No encontramos mascotas con ese nombre.'
                    : 'Aún no tienes mascotas registradas.',
                style: const TextStyle(
                  color: Color(0xff52675e),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!searching) ...[
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'El personal de EIVET registrará tus mascotas para que aparezcan aquí.',
                  style: TextStyle(color: Color(0xff83948c), fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final pet = pets[index];
          return _PetCard(
            pet: pet,
            onOpen: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PetDetailScreen(pet: pet),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    required this.onOpen,
  });

  final Registro pet;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = _petAccent(pet.especie);
    final details = <String>[
      if (pet.especie.isNotEmpty) pet.especie,
      if (pet.raza.isNotEmpty) pet.raza,
    ].join(' • ');
    final traits = <String>[
      if (pet.sexo.isNotEmpty) pet.sexo,
      _petAge(pet.fechaNacimiento),
    ].where((value) => value.isNotEmpty).join(' • ');

    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x160d3125),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Row(
          children: [
            Container(width: 5, height: 100, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                child: Row(
                  children: [
                    _PetPhoto(url: pet.fotografiaUrl),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pet.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff14251f),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (details.isNotEmpty)
                            Text(
                              details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff586a63),
                                fontSize: 14,
                              ),
                            ),
                          if (traits.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              traits,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xff586a63),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetPhoto extends StatelessWidget {
  const _PetPhoto({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: SizedBox(
        width: 80,
        height: 80,
        child: imageUrl.isEmpty
            ? _placeholder()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() => const ColoredBox(
    color: Color(0xffeef3f0),
    child: Center(
      child: Icon(Icons.pets_rounded, size: 32, color: Color(0xff789086)),
    ),
  );
}

Color _petAccent(String species) {
  final normalized = species.toLowerCase();
  if (normalized.contains('gato') || normalized.contains('felino')) {
    return const Color(0xff2d7ed2);
  }
  return const Color(0xfff1b52b);
}

String _petAge(DateTime? birthday) {
  if (birthday == null) return '';
  final now = DateTime.now();
  var years = now.year - birthday.year;
  if (DateTime(
    now.year,
    birthday.month,
    birthday.day,
  ).isAfter(DateTime(now.year, now.month, now.day))) {
    years--;
  }
  if (years > 0) return '$years ${years == 1 ? 'año' : 'años'}';

  var months = (now.year - birthday.year) * 12 + now.month - birthday.month;
  if (now.day < birthday.day) months--;
  if (months > 0) return '$months ${months == 1 ? 'mes' : 'meses'}';
  return 'Menos de 1 mes';
}
