import '../../models/movil/registro.dart';

abstract class RegistroRepository {
  Future<List<Registro>> fetchAll();
  Future<void> create(Registro pet);
  Future<void> update(Registro pet);
  Future<void> delete(String id);
}
