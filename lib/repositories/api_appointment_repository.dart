import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/appointment_request.dart';
import 'appointment_repository.dart';

/// Contrato REST previsto para NestJS: /solicitudes-citas.
class ApiAppointmentRepository implements AppointmentRepository {
  ApiAppointmentRepository({required this.client, required this.baseUri});
  final http.Client client;
  final Uri baseUri;
  Uri get _base => baseUri.resolve('solicitudes-citas');
  Uri _byId(String id) => baseUri.resolve('solicitudes-citas/$id');
  static const _headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  Future<List<AppointmentRequest>> fetchAll() async {
    final response = await client.get(_base, headers: _headers);
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    final rows = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> ? decoded['data'] : <dynamic>[]);
    if (rows is! List)
      throw const FormatException('La API no devolvió solicitudes de citas.');
    return rows
        .whereType<Map<String, dynamic>>()
        .map(AppointmentRequest.fromApi)
        .toList(growable: false);
  }

  @override
  Future<void> create(AppointmentRequest request) async {
    final response = await client.post(
      _base,
      headers: _headers,
      body: jsonEncode(request.toApi()),
    );
    _ensureSuccess(response);
  }

  @override
  Future<void> update(AppointmentRequest request) async {
    final id = request.id;
    if (id == null) throw ArgumentError('La solicitud no tiene identificador.');
    final response = await client.patch(
      _byId(id),
      headers: _headers,
      body: jsonEncode(request.toApi()),
    );
    _ensureSuccess(response);
  }

  @override
  Future<void> delete(String id) async {
    final response = await client.delete(_byId(id), headers: _headers);
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception(
      'El servicio de citas respondió con el código ${response.statusCode}.',
    );
  }
}
