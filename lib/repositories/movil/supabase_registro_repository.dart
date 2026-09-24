import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/movil/registro.dart'; import 'registro_repository.dart';
class SupabaseRegistroRepository implements RegistroRepository {
  final _client = Supabase.instance.client;

  @override
  Future<List<Registro>> fetchAll() async {
    final rows = await _client.from('mascotas').select()
        .eq('cliente_id', _requireUserId()).order('nombre');
    return (rows as List)
        .map((r) => Registro.fromJson(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  @override
  Future<void> create(Registro pet) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No hay una sesión activa.');
    await _client.from('mascotas').insert({...pet.toJson(), 'cliente_id': userId});
  }

  @override
  Future<void> update(Registro pet) async {
    if (pet.id == null) throw ArgumentError('La mascota no tiene identificador.');
    await _client.from('mascotas').update(pet.toJson())
        .eq('id', pet.id!).eq('cliente_id', _requireUserId());
  }

  @override
  Future<void> delete(String id) => _client.from('mascotas').delete()
      .eq('id', id).eq('cliente_id', _requireUserId());

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No hay una sesión activa.');
    return userId;
  }
}
