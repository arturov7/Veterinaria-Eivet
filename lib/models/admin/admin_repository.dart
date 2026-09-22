import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_models.dart';

abstract class AdminRepository {
  Future<List<Owner>> owners();
  Future<void> saveOwner(Owner v);
  Future<void> deleteOwner(String id);
  Future<List<AdminPet>> pets();
  Future<void> savePet(AdminPet v);
  Future<void> deletePet(String id);
  Future<List<AdminRecord>> records(String type);
  Future<void> saveRecord(String type, AdminRecord v);
  Future<void> deleteRecord(String type, String id);
}

class DemoAdminRepository implements AdminRepository {
  final _owners = <Owner>[
    const Owner(
      id: 'o1',
      name: 'Ana Pérez',
      phone: '70000001',
      email: 'ana@demo.bo',
    ),
  ];
  final _pets = <AdminPet>[
    AdminPet(
      id: 'p1',
      ownerId: 'o1',
      ownerName: 'Ana Pérez',
      name: 'Max',
      species: 'Perro',
      breed: 'Labrador',
      sex: 'Macho',
      birthDate: DateTime(2022, 5, 10),
      weight: 24,
    ),
  ];
  final _data = <String, List<AdminRecord>>{
    'citas': [],
    'consultas': [],
    'tratamientos': [],
    'vacunas': [],
  };
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  @override
  Future<List<Owner>> owners() async => List.of(_owners);
  @override
  Future<void> saveOwner(Owner v) async {
    final x = Owner(
      id: v.id ?? _id(),
      name: v.name,
      ci: v.ci,
      phone: v.phone,
      email: v.email,
      address: v.address,
    );
    final i = _owners.indexWhere((e) => e.id == x.id);
    i < 0 ? _owners.add(x) : _owners[i] = x;
  }

  @override
  Future<void> deleteOwner(String id) async =>
      _owners.removeWhere((e) => e.id == id);
  @override
  Future<List<AdminPet>> pets() async => List.of(_pets);
  @override
  Future<void> savePet(AdminPet v) async {
    final owner = _owners.where((x) => x.id == v.ownerId).firstOrNull;
    final x = AdminPet(
      id: v.id ?? _id(),
      ownerId: v.ownerId,
      ownerName: owner?.name ?? '',
      name: v.name,
      species: v.species,
      breed: v.breed,
      sex: v.sex,
      birthDate: v.birthDate,
      weight: v.weight,
      color: v.color,
      notes: v.notes,
    );
    final i = _pets.indexWhere((e) => e.id == x.id);
    i < 0 ? _pets.add(x) : _pets[i] = x;
  }

  @override
  Future<void> deletePet(String id) async =>
      _pets.removeWhere((e) => e.id == id);
  @override
  Future<List<AdminRecord>> records(String t) async => List.of(_data[t]!);
  @override
  Future<void> saveRecord(String t, AdminRecord v) async {
    final x = AdminRecord(
      id: v.id ?? _id(),
      petId: v.petId,
      ownerId: v.ownerId,
      relatedId: v.relatedId,
      title: v.title,
      detail: v.detail,
      date: v.date,
      status: v.status,
    );
    final a = _data[t]!;
    final i = a.indexWhere((e) => e.id == x.id);
    i < 0 ? a.add(x) : a[i] = x;
  }

  @override
  Future<void> deleteRecord(String t, String id) async =>
      _data[t]!.removeWhere((e) => e.id == id);
}

class SupabaseAdminRepository implements AdminRepository {
  final _db = Supabase.instance.client;
  Future<List<T>> _list<T>(
    String table,
    T Function(Map<String, dynamic>) f, [
    String? select,
  ]) async {
    final r = await _db
        .from(table)
        .select(select ?? '*')
        .order('created_at', ascending: false);
    return (r as List).map((e) => f(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> _save(String t, String? id, Map<String, dynamic> m) =>
      id == null ? _db.from(t).insert(m) : _db.from(t).update(m).eq('id', id);
  @override
  Future<List<Owner>> owners() => _list('propietarios', Owner.fromMap);
  @override
  Future<void> saveOwner(Owner v) => _save('propietarios', v.id, v.toMap());
  @override
  Future<void> deleteOwner(String id) =>
      _db.from('propietarios').delete().eq('id', id);
  @override
  Future<List<AdminPet>> pets() =>
      _list('mascotas', AdminPet.fromMap, '*, propietarios(nombre_completo)');
  @override
  Future<void> savePet(AdminPet v) => _save('mascotas', v.id, v.toMap());
  @override
  Future<void> deletePet(String id) =>
      _db.from('mascotas').delete().eq('id', id);
  @override
  Future<List<AdminRecord>> records(String t) => _list(
    t,
    (m) => AdminRecord.fromMap(m, type: t),
    // Solo citas posee una relación directa con propietarios. Pedirla para
    // vacunas/consultas/tratamientos provoca un error de relación en PostgREST.
    t == 'citas'
        ? '*, mascotas(nombre), propietarios(nombre_completo)'
        : '*, mascotas(nombre)',
  );
  @override
  Future<void> saveRecord(String t, AdminRecord v) =>
      _save(t, v.id, v.toMap(t));
  @override
  Future<void> deleteRecord(String t, String id) =>
      _db.from(t).delete().eq('id', id);
}
