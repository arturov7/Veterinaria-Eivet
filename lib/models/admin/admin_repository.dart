import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_models.dart';

abstract class AdminRepository {
  Future<List<Owner>> owners();
  Future<void> createClientAccount(Owner v, String password);
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
  final _owners = <Owner>[];
  final _pets = <AdminPet>[];
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
  Future<void> createClientAccount(Owner v, String password) async =>
      throw StateError('Las cuentas móviles requieren Supabase.');
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
    final ordered = table == 'vacunas'
        ? await _db.from(table).select(select ?? '*').order('proxima_dosis', ascending: true)
        : await _db.from(table).select(select ?? '*').order('created_at', ascending: false);
    return (ordered as List).map((e) => f(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> _save(String t, String? id, Map<String, dynamic> m) =>
      id == null ? _db.from(t).insert(m) : _db.from(t).update(m).eq('id', id);
  @override
  Future<List<Owner>> owners() async {
    final manual = await _list('propietarios', Owner.fromMap);
    final accounts = await _list(
      'clientes',
      Owner.fromClientMap,
      'id,nombre,telefono,direccion,correo,created_at',
    );
    // El trigger de Auth también crea una fila en clientes para el personal.
    // Esas cuentas no deben ofrecerse como propietarios de mascotas.
    final staffRows = await _db.from('perfiles').select('id');
    final staffIds = (staffRows as List)
        .map((row) => (row as Map)['id']?.toString())
        .toSet();
    return [
      ...accounts.where((account) => !staffIds.contains(account.id)),
      ...manual,
    ];
  }
  @override
  Future<void> createClientAccount(Owner v, String password) async {
    final token = _db.auth.currentSession?.accessToken;
    if (token == null) throw StateError('Inicia sesión como administrador.');
    try {
      await _db.functions.invoke(
        'crear-propietario',
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'nombre': v.name.trim(),
          'correo': v.email.trim().toLowerCase(),
          'contrasena': password,
          'telefono': v.phone.trim(),
          'direccion': v.address.trim(),
        },
      );
    } on FunctionException catch (error) {
      final details = error.details;
      if (details is Map && details['error'] is String) {
        throw StateError(details['error'] as String);
      }
      if (error.status == 0) {
        throw StateError(
          'No se pudo contactar la función crear-propietario. Verifica que esté desplegada en este proyecto y que el preflight OPTIONS responda 200.',
        );
      }
      throw StateError(
        error.status == 404
            ? 'Falta desplegar la función crear-propietario en Supabase.'
            : 'No se pudo crear la cuenta (${error.status}).',
      );
    }
  }
  @override
  Future<void> saveOwner(Owner v) => _save('propietarios', v.id, v.toMap());
  @override
  Future<void> deleteOwner(String id) =>
      _db.from('propietarios').delete().eq('id', id);
  @override
  Future<List<AdminPet>> pets() async {
    final rows = await _db
        .from('mascotas')
        .select('*, propietarios(nombre_completo), clientes(nombre)')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => AdminPet.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
  @override
  Future<void> savePet(AdminPet v) async {
    final linkedToClient = v.clientId != null && v.clientId!.isNotEmpty;
    final linkedToManualOwner = v.ownerId.isNotEmpty;
    if (linkedToClient == linkedToManualOwner) {
      throw StateError('Selecciona una sola cuenta o ficha de propietario.');
    }
    if (v.id == null) {
      await _db.from('mascotas').insert(v.toMap()).select('id').single();
    } else {
      await _db.from('mascotas').update(v.toMap()).eq('id', v.id!).select('id').single();
    }
  }
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
  Future<void> saveRecord(String t, AdminRecord v) async {
    final values = v.toMap(t);
    if (v.id == null) {
      await _db.from(t).insert(values).select('id').single();
    } else {
      await _db.from(t).update(values).eq('id', v.id!).select('id').single();
    }
  }
  @override
  Future<void> deleteRecord(String t, String id) =>
      _db.from(t).delete().eq('id', id);
}
