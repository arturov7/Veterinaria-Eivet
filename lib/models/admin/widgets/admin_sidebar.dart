import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';
import 'eivet_logo.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.index,
    required this.onSelect,
    this.name = 'Personal EIVET',
    this.role = 'Personal veterinario',
    this.onLogout,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final String name;
  final String role;
  final VoidCallback? onLogout;

  static const labels = [
    'Dashboard',
    'Citas veterinarias',
    'Propietarios',
    'Mascotas',
    'Consultas e historial',
    'Vacunas y tratamientos',
    'Especialidad Oncológica',
    'Reportes',
    'Configuración / Seguridad',
  ];
  static const icons = [
    Icons.dashboard_outlined,
    Icons.calendar_month_outlined,
    Icons.badge_outlined,
    Icons.pets_outlined,
    Icons.medical_information_outlined,
    Icons.vaccines_outlined,
    Icons.biotech_outlined,
    Icons.analytics_outlined,
    Icons.shield_outlined,
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: 256,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff073d30), Color(0xff00291f)],
      ),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 16, 20),
          child: Row(
            children: [
              const EivetLogo(size: 42),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Veterinaria EIVET',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '● PANEL VETERINARIO / ADMIN',
                      style: TextStyle(
                        color: const Color(0xff8ef0bd),
                        fontSize: 9,
                        letterSpacing: .45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 17,
                  color: const Color(0xff9bf0c2),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Especialidad Oncológica',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'ACTIVA',
                  style: TextStyle(
                    fontSize: 9,
                    color: const Color(0xffffdc84),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: labels.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              final selected = index == i;
              return Material(
                color: selected ? AdminTheme.emerald : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icons[i],
                          size: 19,
                          color: selected
                              ? Colors.white
                              : const Color(0xffb8d3c6),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xffe2eee8),
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .07),
            border: const Border(top: BorderSide(color: Colors.white24)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AdminTheme.emerald,
                    radius: 19,
                    child: Text(
                      name.isEmpty ? 'E' : name.trim()[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: const Color(0xffb8d3c6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffdcfce7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 12,
                          color: AdminTheme.emerald,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Acceso seguro',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xff065f46),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, size: 15),
                    label: const Text('Salir'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xffdc2626),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
