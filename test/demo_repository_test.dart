import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/models/movil/pet_api_mapper.dart';
import 'package:proyecto_final_360/models/movil/pet_details.dart';
import 'package:proyecto_final_360/models/movil/appointment_request.dart';
import 'package:proyecto_final_360/repositories/movil/demo_appointment_repository.dart';
import 'package:proyecto_final_360/repositories/movil/demo_pet_care_repository.dart';
import 'package:proyecto_final_360/repositories/movil/demo_registro_repository.dart';

void main() {
  test('modo demo muestra fichas de mascotas', () async {
    final repository = DemoRegistroRepository();
    final pets = await repository.fetchAll();

    expect(pets, isNotEmpty);
    expect(pets.first.titulo, 'Max');
  });

  test('convierte datos de mascota a descripción consultable', () {
    const details = PetDetails(
      species: 'Gato',
      breed: 'Mestizo',
      gender: 'Hembra',
      birthDate: '2023-04-01',
      notes: 'Control anual pendiente',
    );

    final restored = PetDetails.fromDescription(details.toDescription());

    expect(restored.species, 'Gato');
    expect(restored.breed, 'Mestizo');
    expect(restored.gender, 'Hembra');
    expect(restored.notes, 'Control anual pendiente');
  });

  test('convierte la respuesta de NestJS a una ficha de consulta', () {
    final restored = PetApiMapper.fromApi(<String, dynamic>{
      'id': '12',
      'nombre': 'Luna',
      'especie': 'Gato',
      'raza': 'Siamés',
      'genero': 'Hembra',
      'fechaNacimiento': '2023-01-15',
      'observaciones': 'Sin alergias',
      'estado': 'activo',
    });

    expect(restored.titulo, 'Luna');
    expect(PetDetails.fromDescription(restored.descripcion).breed, 'Siamés');
  });

  test('CRUD de solicitudes de citas funciona en modo demo', () async {
    final repository = DemoAppointmentRepository();
    final request = AppointmentRequest(
      petId: 'demo-1',
      petName: 'Max',
      scheduledAt: DateTime(2026, 9, 2, 9),
      reason: 'Control general',
      status: 'pendiente',
    );

    await repository.create(request);
    final created = (await repository.fetchAll()).single;
    await repository.update(created.copyWith(reason: 'Control y vacunas'));
    expect((await repository.fetchAll()).single.reason, 'Control y vacunas');
    await repository.delete(created.id!);
    expect(await repository.fetchAll(), isEmpty);
  });

  test('modo demo ofrece cuidados sin requerir Supabase', () async {
    const repository = DemoPetCareRepository();

    final care = await repository.fetch(petId: 'demo-1');

    expect(care.vaccines, isNotEmpty);
    expect(care.treatments, isNotEmpty);
  });
}
