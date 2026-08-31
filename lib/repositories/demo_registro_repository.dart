import '../models/registro.dart';
import 'registro_repository.dart';

class DemoRegistroRepository implements RegistroRepository {
  final List<Registro> _items = <Registro>[
    Registro(
      id: 'demo-1',
      titulo: 'Max',
      especie: 'Perro',
      raza: 'Labrador',
      sexo: 'Macho',
      fechaNacimiento: DateTime(2022, 5, 10),
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Registro>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<Registro>.unmodifiable(_items);
  }

  @override
  Future<void> create(Registro pet) async {
    _items.add(Registro(id: DateTime.now().microsecondsSinceEpoch.toString(), titulo: pet.titulo, especie: pet.especie, raza: pet.raza, sexo: pet.sexo, fechaNacimiento: pet.fechaNacimiento, fotografiaUrl: pet.fotografiaUrl));
  }

  @override
  Future<void> update(Registro pet) async {
    final index = _items.indexWhere((item) => item.id == pet.id);
    if (index >= 0) _items[index] = pet;
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((item) => item.id == id);
}
