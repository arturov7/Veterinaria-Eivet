import '../../models/movil/pet_care_snapshot.dart';

abstract class PetCareRepository {
  /// Devuelve cuidados del cliente. Si [petId] es nulo, incluye sus mascotas.
  Future<PetCareSnapshot> fetch({String? petId});
}
