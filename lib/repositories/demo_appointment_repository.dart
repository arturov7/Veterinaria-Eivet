import '../models/appointment_request.dart';
import 'appointment_repository.dart';

class DemoAppointmentRepository implements AppointmentRepository {
  final List<AppointmentRequest> _items = <AppointmentRequest>[];

  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<AppointmentRequest>> fetchAll() async {
    await _delay();
    return List<AppointmentRequest>.unmodifiable(_items);
  }

  @override
  Future<void> create(AppointmentRequest request) async {
    await _delay();
    _items.insert(
      0,
      request.copyWith(
        id: 'cita-${DateTime.now().microsecondsSinceEpoch}',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> update(AppointmentRequest request) async {
    await _delay();
    final index = _items.indexWhere((item) => item.id == request.id);
    if (index < 0) throw StateError('No se encontró la solicitud de cita.');
    _items[index] = request;
  }

  @override
  Future<void> delete(String id) async {
    await _delay();
    _items.removeWhere((item) => item.id == id);
  }
}
