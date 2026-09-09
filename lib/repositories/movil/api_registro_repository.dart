import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/movil/pet_api_mapper.dart';
import '../../models/movil/registro.dart';
import 'registro_repository.dart';

/// Lectura REST para clientes: GET /mascotas.
class ApiRegistroRepository implements RegistroRepository {
  ApiRegistroRepository({required this.client, required this.baseUri});
  final http.Client client;
  final Uri baseUri;
  Uri get _petsUri => baseUri.resolve('mascotas');

  @override
  Future<List<Registro>> fetchAll() async {
    final response = await client.get(_petsUri, headers: _headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'El servicio de mascotas respondió con el código ${response.statusCode}.',
      );
    }
    final decoded = jsonDecode(response.body);
    final rows = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> ? decoded['data'] : <dynamic>[]);
    if (rows is! List)
      throw const FormatException('La API no devolvió una lista de mascotas.');
    return rows
        .whereType<Map<String, dynamic>>()
        .map(PetApiMapper.fromApi)
        .toList(growable: false);
  }

  @override
  Future<void> create(Registro pet) =>
      throw UnsupportedError('La API REST de clientes es de solo lectura.');

  @override
  Future<void> update(Registro pet) =>
      throw UnsupportedError('La API REST de clientes es de solo lectura.');

  @override
  Future<void> delete(String id) =>
      throw UnsupportedError('La API REST de clientes es de solo lectura.');

  Map<String, String> get _headers => const <String, String>{
    'Accept': 'application/json',
  };
}
