import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/movil/appointment_request.dart';
import 'appointment_repository.dart';

class SupabaseAppointmentRepository implements AppointmentRepository {
  SupabaseAppointmentRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No hay una sesión activa.');
    return id;
  }

  @override
  Future<List<AppointmentRequest>> fetchAll() async {
    final userId = _userId;
    final ownedPets = await _client.from('mascotas').select('id')
        .eq('cliente_id', userId);
    final petIds = (ownedPets as List)
        .map((row) => row['id'].toString())
        .toList(growable: false);
    if (petIds.isEmpty) return <AppointmentRequest>[];
    final rows = await _client.from('citas')
        .select('*, mascotas(nombre)')
        .eq('cliente_id', userId)
        .inFilter('mascota_id', petIds)
        .order('fecha_hora');
    return (rows as List).map((row) => AppointmentRequest.fromJson(
        Map<String, dynamic>.from(row as Map))).toList();
  }

  @override
  Future<void> create(AppointmentRequest request) async {
    await _requireOwnedPet(request.petId);
    await _client.from('citas').insert({
      ...request.toJson(),
      'cliente_id': _userId,
      'estado': 'Pendiente',
    });
  }

  @override
  Future<void> update(AppointmentRequest request) async {
    if (request.id == null) throw ArgumentError('La cita no tiene identificador.');
    await _requireOwnedPet(request.petId);
    await _client.from('citas').update({
      'mascota_id': request.petId,
      'fecha_hora': request.scheduledAt.toIso8601String(),
      'motivo': request.reason.trim(),
      'estado': 'Pendiente',
    }).eq('id', request.id!).eq('cliente_id', _userId);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('citas').update({'estado': 'Cancelada'})
        .eq('id', id).eq('cliente_id', _userId);
  }

  Future<void> _requireOwnedPet(String petId) async {
    final pet = await _client.from('mascotas').select('id')
        .eq('id', petId).eq('cliente_id', _userId).maybeSingle();
    if (pet == null) {
      throw StateError('La mascota no pertenece a la cuenta actual.');
    }
  }
}
