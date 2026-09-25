import '../../models/movil/pet_care_snapshot.dart';
import 'pet_care_repository.dart';

class DemoPetCareRepository implements PetCareRepository {
  const DemoPetCareRepository();

  @override
  Future<PetCareSnapshot> fetch({String? petId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (petId != null && petId != 'demo-1') return PetCareSnapshot.empty;
    return const PetCareSnapshot(
      vaccines: <Map<String, dynamic>>[
        <String, dynamic>{
          'nombre': 'Vacuna antirrábica',
          'proxima_dosis': '2026-11-10',
          'estado': 'Pendiente',
          'mascotas': <String, dynamic>{'nombre': 'Max'},
        },
      ],
      treatments: <Map<String, dynamic>>[
        <String, dynamic>{
          'fecha': '2026-09-01',
          'motivo': 'Control general',
          'tratamiento': 'Seguimiento preventivo',
          'indicaciones': 'Mantener su calendario de vacunas al día.',
          'proximo_control': '2026-12-01',
          'mascotas': <String, dynamic>{'nombre': 'Max'},
        },
      ],
      appointments: <Map<String, dynamic>>[],
      consultations: <Map<String, dynamic>>[
        <String, dynamic>{
          'fecha': '2026-09-01',
          'motivo': 'Control general',
          'diagnostico': 'Buen estado de salud.',
          'mascotas': <String, dynamic>{'nombre': 'Max'},
        },
      ],
    );
  }
}
