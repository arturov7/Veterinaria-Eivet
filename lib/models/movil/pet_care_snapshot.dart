/// Datos clínicos de lectura asociados a una mascota.
///
/// Se mantiene independiente del proveedor de datos para que la interfaz no
/// dependa directamente de Supabase ni de una futura API.
class PetCareSnapshot {
  const PetCareSnapshot({
    this.vaccines = const <Map<String, dynamic>>[],
    this.treatments = const <Map<String, dynamic>>[],
    this.appointments = const <Map<String, dynamic>>[],
    this.consultations = const <Map<String, dynamic>>[],
  });

  final List<Map<String, dynamic>> vaccines;
  final List<Map<String, dynamic>> treatments;
  final List<Map<String, dynamic>> appointments;
  final List<Map<String, dynamic>> consultations;

  static const empty = PetCareSnapshot();
}
