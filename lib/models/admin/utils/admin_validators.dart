class AdminValidators {
  static String? required(String? v, [String label = 'Este campo']) =>
      v == null || v.trim().isEmpty ? '$label es obligatorio.' : null;
  static String? email(String? v) =>
      v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
      ? 'Correo electrónico no válido.'
      : null;
}
