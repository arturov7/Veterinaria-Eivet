import 'package:flutter/material.dart';

enum ServiceAction { showNotice, openContext, openPets }

class VeterinaryService {
  const VeterinaryService({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.action,
    this.badge,
    this.message,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final ServiceAction action;
  final String? badge;
  final String? message;
}

class ProjectFeature {
  const ProjectFeature({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;
}
