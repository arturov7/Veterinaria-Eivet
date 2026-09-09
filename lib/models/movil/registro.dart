/// Mascota registrada para el cliente autenticado.
class Registro {
  const Registro({
    this.id,
    this.clienteId,
    required this.titulo,
    this.especie = '',
    this.raza = '',
    this.sexo = '',
    this.fechaNacimiento,
    this.fotografiaUrl,
    this.createdAt,
  });

  final String? id;
  final String? clienteId;
  final String titulo;
  final String especie;
  final String raza;
  final String sexo;
  final DateTime? fechaNacimiento;
  final String? fotografiaUrl;
  final DateTime? createdAt;

  String get descripcion => [
        if (especie.isNotEmpty) 'Especie: $especie',
        if (raza.isNotEmpty) 'Raza: $raza',
        if (sexo.isNotEmpty) 'Género: $sexo',
        if (fechaNacimiento != null) 'Nacimiento: ${fechaNacimiento!.toIso8601String().split('T').first}',
      ].join('\n');
  String get estado => 'Activo';

  factory Registro.fromJson(Map<String, dynamic> json) => Registro(
        id: json['id']?.toString(),
        clienteId: json['cliente_id']?.toString(),
        titulo: json['nombre']?.toString() ?? 'Mascota',
        especie: json['especie']?.toString() ?? '',
        raza: json['raza']?.toString() ?? '',
        sexo: json['sexo']?.toString() ?? '',
        fechaNacimiento: DateTime.tryParse(json['fecha_nacimiento']?.toString() ?? ''),
        fotografiaUrl: json['fotografia_url']?.toString(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'nombre': titulo.trim(),
        'especie': especie.trim().isEmpty ? null : especie.trim(),
        'raza': raza.trim().isEmpty ? null : raza.trim(),
        'sexo': sexo.trim().isEmpty ? null : sexo.trim(),
        'fecha_nacimiento': fechaNacimiento == null
            ? null
            : '${fechaNacimiento!.year.toString().padLeft(4, '0')}-${fechaNacimiento!.month.toString().padLeft(2, '0')}-${fechaNacimiento!.day.toString().padLeft(2, '0')}',
        'fotografia_url': fotografiaUrl?.trim().isEmpty ?? true ? null : fotografiaUrl!.trim(),
      };
}
