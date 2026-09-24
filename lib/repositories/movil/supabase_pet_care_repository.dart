import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/movil/pet_care_snapshot.dart';
import 'pet_care_repository.dart';

class SupabasePetCareRepository implements PetCareRepository {
  SupabasePetCareRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<PetCareSnapshot> fetch({String? petId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No hay una sesión activa.');
    final ownedPets = await _client.from('mascotas').select('id')
        .eq('cliente_id', userId);
    final petIds = (ownedPets as List)
        .map((row) => row['id'].toString())
        .toList(growable: false);
    if (petIds.isEmpty || (petId != null && !petIds.contains(petId))) {
      return PetCareSnapshot.empty;
    }
    final visiblePetIds = petId == null ? petIds : <String>[petId];
    dynamic vaccines = _client
        .from('vacunas')
        .select(
          'nombre, fecha_aplicacion, proxima_dosis, estado, mascotas(nombre)',
        ).inFilter('mascota_id', visiblePetIds);
    dynamic treatments = _client
        .from('historiales_clinicos')
        .select(
          'fecha, motivo, diagnostico, tratamiento, receta, indicaciones, proximo_control, mascotas(nombre)',
        ).inFilter('mascota_id', visiblePetIds);
    dynamic appointments = _client
        .from('citas')
        .select('fecha_hora, motivo, estado')
        .eq('cliente_id', userId).inFilter('mascota_id', visiblePetIds);
    final staffTreatments = _client
        .from('tratamientos')
        .select('nombre, indicaciones, fecha_inicio, fecha_fin, estado, mascotas(nombre)')
        .inFilter('mascota_id', visiblePetIds);
    treatments = treatments.eq('autorizado', true);
    final results = await Future.wait<dynamic>([
      vaccines.order('proxima_dosis'),
      treatments.order('fecha', ascending: false),
      appointments.order('fecha_hora'),
      staffTreatments.order('fecha_inicio', ascending: false),
    ]);
    final visibleTreatments = _rows(results[1]);
    for (final row in _rows(results[3])) {
      visibleTreatments.add({
        'tratamiento': row['nombre'],
        'indicaciones': row['indicaciones'],
        'fecha_inicio': row['fecha_inicio'],
        'fecha_fin': row['fecha_fin'],
        'estado': row['estado'],
        'mascotas': row['mascotas'],
      });
    }
    return PetCareSnapshot(
      vaccines: _rows(results[0]),
      treatments: visibleTreatments,
      appointments: _rows(results[2]),
    );
  }

  List<Map<String, dynamic>> _rows(dynamic rows) => (rows as List)
      .map((row) => Map<String, dynamic>.from(row as Map))
      .toList();
}
