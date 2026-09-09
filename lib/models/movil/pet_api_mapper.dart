import 'registro.dart';

class PetApiMapper {
  const PetApiMapper._();

  static Registro fromApi(Map<String, dynamic> data) {
    return Registro(
      id: data['id']?.toString(),
      titulo: data['nombre']?.toString() ?? '',
      especie: data['especie']?.toString() ?? '',
      raza: data['raza']?.toString() ?? '',
      sexo: data['genero']?.toString() ?? '',
      fechaNacimiento: DateTime.tryParse(data['fechaNacimiento']?.toString() ?? ''),
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? ''),
    );
  }
}
