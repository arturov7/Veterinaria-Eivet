class Owner {
  const Owner({
    this.id,
    required this.name,
    this.ci = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.isClientAccount = false,
  });
  final String? id;
  final String name, ci, phone, email, address;
  final bool isClientAccount;
  factory Owner.fromMap(Map<String, dynamic> m) => Owner(
    id: m['id']?.toString(),
    name: m['nombre_completo']?.toString() ?? '',
    ci: m['ci']?.toString() ?? '',
    phone: m['telefono']?.toString() ?? '',
    email: m['correo']?.toString() ?? '',
    address: m['direccion']?.toString() ?? '',
  );
  factory Owner.fromClientMap(Map<String, dynamic> m) => Owner(
    id: m['id']?.toString(),
    name: m['nombre']?.toString() ?? '',
    phone: m['telefono']?.toString() ?? '',
    email: m['correo']?.toString() ?? '',
    address: m['direccion']?.toString() ?? '',
    isClientAccount: true,
  );
  Map<String, dynamic> toMap() => {
    'nombre_completo': name.trim(),
    'ci': ci.trim(),
    'telefono': phone.trim(),
    'correo': email.trim(),
    'direccion': address.trim(),
  };
}

class AdminPet {
  const AdminPet({
    this.id,
    required this.ownerId,
    required this.name,
    this.species = '',
    this.breed = '',
    this.sex = '',
    this.birthDate,
    this.weight,
    this.color = '',
    this.notes = '',
    this.ownerName = '',
    this.clientId,
  });
  final String? id;
  final String ownerId, name, species, breed, sex, color, notes, ownerName;
  final String? clientId;
  final DateTime? birthDate;
  final double? weight;
  factory AdminPet.fromMap(Map<String, dynamic> m) {
    final o = m['propietarios'];
    final client = m['clientes'];
    return AdminPet(
      id: m['id']?.toString(),
      ownerId: m['propietario_id']?.toString() ?? '',
      clientId: m['cliente_id']?.toString(),
      name: m['nombre']?.toString() ?? '',
      species: m['especie']?.toString() ?? '',
      breed: m['raza']?.toString() ?? '',
      sex: m['sexo']?.toString() ?? '',
      birthDate: DateTime.tryParse(m['fecha_nacimiento']?.toString() ?? ''),
      weight: double.tryParse(m['peso']?.toString() ?? ''),
      color: m['color']?.toString() ?? '',
      notes: m['observaciones']?.toString() ?? '',
      ownerName: o is Map
          ? o['nombre_completo']?.toString() ?? ''
          : client is Map ? client['nombre']?.toString() ?? '' : '',
    );
  }
  Map<String, dynamic> toMap() => {
    'propietario_id': ownerId.isEmpty ? null : ownerId,
    'cliente_id': clientId == null || clientId!.isEmpty ? null : clientId,
    'nombre': name.trim(),
    'especie': species.trim(),
    'raza': breed.trim(),
    'sexo': sex.trim(),
    'fecha_nacimiento': birthDate?.toIso8601String().split('T').first,
    'peso': weight,
    'color': color.trim(),
    'observaciones': notes.trim(),
  };
  int get age => birthDate == null
      ? 0
      : DateTime.now().difference(birthDate!).inDays ~/ 365;
}

class AdminRecord {
  const AdminRecord({
    this.id,
    required this.petId,
    this.ownerId = '',
    this.relatedId = '',
    required this.title,
    this.detail = '',
    this.date,
    this.status = '',
    this.petName = '',
    this.ownerName = '',
    this.appliedDate,
    this.clientId,
  });
  final String? id;
  final String petId,
      ownerId,
      relatedId,
      title,
      detail,
      status,
      petName,
      ownerName;
  final DateTime? date;
  final DateTime? appliedDate;
  final String? clientId;
  factory AdminRecord.fromMap(Map<String, dynamic> m, {required String type}) {
    final p = m['mascotas'];
    final o = m['propietarios'];
    final title = type == 'citas'
        ? m['motivo']
        : type == 'consultas'
        ? m['motivo']
        : m['nombre'];
    return AdminRecord(
      id: m['id']?.toString(),
      petId: m['mascota_id']?.toString() ?? '',
      ownerId: m['propietario_id']?.toString() ?? '',
      clientId: m['cliente_id']?.toString(),
      relatedId:
          m[type == 'tratamientos' ? 'consulta_id' : '']?.toString() ?? '',
      title: title?.toString() ?? '',
      detail:
          (m['diagnostico'] ?? m['indicaciones'] ?? m['observaciones'] ?? '')
              .toString(),
      date: DateTime.tryParse(
        (m[type == 'citas'
                    ? 'fecha_hora'
                    : type == 'vacunas'
                    ? 'proxima_dosis'
                    : type == 'tratamientos'
                    ? 'fecha_inicio'
                    : 'fecha'] ??
                '')
            .toString(),
      ),
      appliedDate: type == 'vacunas'
          ? DateTime.tryParse(m['fecha_aplicacion']?.toString() ?? '')
          : null,
      status: m['estado']?.toString() ?? '',
      petName: p is Map ? p['nombre']?.toString() ?? '' : '',
      ownerName: o is Map ? o['nombre_completo']?.toString() ?? '' : '',
    );
  }
  Map<String, dynamic> toMap(String type) {
    final map = <String, dynamic>{'mascota_id': petId};
    if (type == 'citas') {
      map.addAll({
        'propietario_id': ownerId.isEmpty ? null : ownerId,
        'cliente_id': clientId,
        'fecha_hora': date?.toIso8601String(),
        'motivo': title,
        'estado': status,
        'observaciones': detail,
      });
    } else if (type == 'consultas') {
      map.addAll({
        'fecha': date?.toIso8601String().split('T').first,
        'motivo': title,
        'diagnostico': detail,
        'observaciones': '',
      });
    } else if (type == 'tratamientos') {
      map.addAll({
        'consulta_id': relatedId.isEmpty ? null : relatedId,
        'nombre': title,
        'indicaciones': detail,
        'fecha_inicio': date?.toIso8601String().split('T').first,
        'estado': status,
      });
    } else {
      map.addAll({
        'nombre': title,
        'fecha_aplicacion': appliedDate?.toIso8601String().split('T').first,
        'proxima_dosis': date?.toIso8601String().split('T').first,
        'observaciones': detail,
      });
    }
    return map;
  }
}
