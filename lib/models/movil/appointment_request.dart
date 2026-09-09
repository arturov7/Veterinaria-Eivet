class AppointmentRequest {
  const AppointmentRequest({
    this.id,
    required this.petId,
    required this.petName,
    required this.scheduledAt,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  final String? id;
  final String petId;
  final String petName;
  final DateTime scheduledAt;
  final String reason;
  final String status;
  final DateTime? createdAt;

  AppointmentRequest copyWith({
    String? id,
    String? petId,
    String? petName,
    DateTime? scheduledAt,
    String? reason,
    String? status,
    DateTime? createdAt,
  }) => AppointmentRequest(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    petName: petName ?? this.petName,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    reason: reason ?? this.reason,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );

  factory AppointmentRequest.fromApi(Map<String, dynamic> map) =>
      AppointmentRequest(
        id: map['id']?.toString(),
        petId: map['mascotaId']?.toString() ?? '',
        petName: map['mascotaNombre']?.toString() ?? 'Mascota',
        scheduledAt:
            DateTime.tryParse(map['fechaHora']?.toString() ?? '') ??
            DateTime.now(),
        reason: map['motivo']?.toString() ?? '',
        status: map['estado']?.toString() ?? 'pendiente',
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
      );

  Map<String, dynamic> toApi() => <String, dynamic>{
    'mascotaId': petId,
    'fechaHora': scheduledAt.toIso8601String(),
    'motivo': reason.trim(),
    'estado': status,
  };
  factory AppointmentRequest.fromJson(Map<String, dynamic> map) => AppointmentRequest(id: map['id']?.toString(), petId: map['mascota_id']?.toString() ?? '', petName: (map['mascotas'] is Map ? (map['mascotas'] as Map)['nombre'] : null)?.toString() ?? 'Mascota', scheduledAt: DateTime.tryParse(map['fecha_hora']?.toString() ?? '') ?? DateTime.now(), reason: map['motivo']?.toString() ?? '', status: map['estado']?.toString() ?? 'Pendiente', createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''));
  Map<String, dynamic> toJson() => {'mascota_id': petId, 'fecha_hora': scheduledAt.toIso8601String(), 'motivo': reason.trim(), 'estado': status};
}
