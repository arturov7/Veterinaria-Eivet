import '../models/appointment_request.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentRequest>> fetchAll();
  Future<void> create(AppointmentRequest request);
  Future<void> update(AppointmentRequest request);
  Future<void> delete(String id);
}
