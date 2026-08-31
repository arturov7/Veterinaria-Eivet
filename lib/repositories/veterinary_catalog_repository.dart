import 'package:flutter/material.dart';

import '../models/veterinary_content.dart';

class VeterinaryCatalogRepository {
  const VeterinaryCatalogRepository();

  List<VeterinaryService> get services => const <VeterinaryService>[
    VeterinaryService(
      icon: Icons.medical_services_outlined,
      title: 'Consulta',
      subtitle: 'Atención general',
      actionLabel: 'Consultar',
      action: ServiceAction.showNotice,
      message: 'Consulta disponibilidad en la recepción de EIVET.',
    ),
    VeterinaryService(
      icon: Icons.vaccines_outlined,
      title: 'Vacunas',
      subtitle: 'Prevención',
      actionLabel: 'Consultar',
      action: ServiceAction.showNotice,
      message: 'Consulta el calendario de vacunación en EIVET.',
    ),
    VeterinaryService(
      icon: Icons.content_cut_outlined,
      title: 'Cirugía',
      subtitle: 'Procedimientos',
      actionLabel: 'Consultar',
      action: ServiceAction.showNotice,
      message: 'EIVET te orientará sobre la atención quirúrgica.',
    ),
    VeterinaryService(
      icon: Icons.pets_outlined,
      title: 'Guardería',
      subtitle: 'Cuidado diario',
      actionLabel: 'Consultar',
      action: ServiceAction.showNotice,
      message: 'Consulta disponibilidad de guardería en EIVET.',
    ),
  ];

  VeterinaryService get oncologyService => const VeterinaryService(
    icon: Icons.favorite_outline,
    title: 'Atención oncológica integral',
    subtitle: 'Cuidado especializado para pacientes felinos y caninos.',
    actionLabel: 'Ver clima y ubicación',
    action: ServiceAction.openContext,
    badge: 'NUEVO SERVICIO',
  );

  List<VeterinaryService> get featuredServices => const <VeterinaryService>[
    VeterinaryService(
      icon: Icons.medical_services_outlined,
      title: 'Consulta veterinaria',
      subtitle: 'Chequeo general y seguimiento clínico',
      actionLabel: 'Ver mis mascotas',
      action: ServiceAction.openPets,
    ),
    VeterinaryService(
      icon: Icons.vaccines_outlined,
      title: 'Vacunación y prevención',
      subtitle: 'Mantén la protección al día',
      actionLabel: 'Ver mis mascotas',
      action: ServiceAction.openPets,
    ),
  ];

  List<ProjectFeature> get projectFeatures => const <ProjectFeature>[
    ProjectFeature(
      icon: Icons.pets_outlined,
      title: 'Gestión de mascotas',
      detail:
          'Consulta de fichas de mascotas registradas por el personal veterinario.',
    ),
    ProjectFeature(
      icon: Icons.cloud_outlined,
      title: 'API REST',
      detail:
          'Consulta el clima actual mediante Open-Meteo para planificar el cuidado.',
    ),
    ProjectFeature(
      icon: Icons.location_on_outlined,
      title: 'GPS y mapa',
      detail:
          'Obtiene ubicación con autorización del cliente y la muestra en un mapa.',
    ),
    ProjectFeature(
      icon: Icons.storage_outlined,
      title: 'Persistencia',
      detail:
          'El perfil, tema y experiencia inicial se guardan localmente en el dispositivo.',
    ),
    ProjectFeature(
      icon: Icons.health_and_safety_outlined,
      title: 'Manejo de estados',
      detail:
          'La interfaz comunica carga, datos disponibles, error, reintento y dato de respaldo.',
    ),
  ];
}
