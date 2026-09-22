import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/models/admin/admin_models.dart';
import 'package:proyecto_final_360/models/admin/admin_repository.dart';
import 'package:proyecto_final_360/models/admin/controllers/admin_controller.dart';

void main() {
  test('CRUD administrativo DEMO funciona', () async {
    final r = DemoAdminRepository();
    final owners = OwnersController(r);
    await owners.load();
    await owners.save(const Owner(name: 'Carlos', email: 'c@demo.bo'));
    final pets = PetsController(r);
    await pets.load();
    await pets.save(
      AdminPet(ownerId: owners.items.last.id!, name: 'Mora', species: 'Gato'),
    );
    expect((await r.pets()).any((p) => p.name == 'Mora'), isTrue);
  });
}
