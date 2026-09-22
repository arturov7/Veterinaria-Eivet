import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/movil/pet_care_snapshot.dart';
import 'pet_care_repository.dart';

class SupabasePetCareRepository implements PetCareRepository {
  SupabasePetCareRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<PetCareSnapshot> fetch({String? petId}) async {
    dynamic vaccines = _client
        .from('vacunas')
        .select(
          'nombre, fecha_aplicacion, proxima_dosis, estado, mascotas(nombre)',
        );
    dynamic treatments = _client
        .from('historiales_clinicos')
        .select(
          'fecha, motivo, diagnostico, tratamiento, receta, indicaciones, proximo_control, mascotas(nombre)',
        );
    dynamic appointments = _client
        .from('citas')
        .select('fecha_hora, motivo, estado');
    if (petId != null) {
      vaccines = vaccines.eq('mascota_id', petId);
      treatments = treatments.eq('mascota_id', petId);
      appointments = appointments.eq('mascota_id', petId);
    }
    final results = await Future.wait<dynamic>([
      vaccines.order('proxima_dosis'),
      treatments.order('fecha', ascending: false),
      appointments.order('fecha_hora'),
    ]);
    return PetCareSnapshot(
      vaccines: _rows(results[0]),
      treatments: _rows(results[1]),
      appointments: _rows(results[2]),
    );
  }

  List<Map<String, dynamic>> _rows(dynamic rows) => (rows as List)
      .map((row) => Map<String, dynamic>.from(row as Map))
      .toList(growable: false);
}
