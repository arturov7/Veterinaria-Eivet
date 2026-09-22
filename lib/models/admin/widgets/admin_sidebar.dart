import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';

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
    'Panel principal',
    'Propietarios',
    'Mascotas',
    'Citas veterinarias',
    'Consultas e historial',
    'Vacunas y tratamientos',
  ];
  static const icons = [
    Icons.dashboard_outlined,
    Icons.badge_outlined,
    Icons.pets_outlined,
    Icons.calendar_month_outlined,
    Icons.medical_information_outlined,
    Icons.vaccines_outlined,
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: 256,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: AdminTheme.border)),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 16, 20),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AdminTheme.forest,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.pets, color: Color(0xff93f3bb)),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Veterinaria EIVET',
                      style: TextStyle(
                        color: AdminTheme.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '● PANEL VETERINARIO / ADMIN',
                      style: TextStyle(
                        color: AdminTheme.emerald,
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
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 17,
                  color: AdminTheme.emerald,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Clínica veterinaria',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminTheme.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'ACTIVA',
                  style: TextStyle(
                    fontSize: 9,
                    color: AdminTheme.emerald,
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
                color: selected ? AdminTheme.forest : Colors.transparent,
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
                          color: selected ? Colors.white : AdminTheme.muted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              color: selected ? Colors.white : AdminTheme.ink,
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
          decoration: const BoxDecoration(
            color: Color(0xfff8f9ff),
            border: Border(top: BorderSide(color: AdminTheme.border)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AdminTheme.forest,
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
                            color: AdminTheme.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AdminTheme.muted,
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
