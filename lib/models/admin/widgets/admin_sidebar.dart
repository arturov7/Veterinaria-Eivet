import 'package:flutter/material.dart';
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
    'Clientes y propietarios',
    'Mascotas',
    'Consultas e historial',
    'Vacunas y tratamientos',
  ];
  static const icons = [
    Icons.dashboard_outlined,
    Icons.calendar_month_outlined,
    Icons.badge_outlined,
    Icons.pets_outlined,
    Icons.medical_information_outlined,
    Icons.vaccines_outlined,
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: 304,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff063c2e), Color(0xff00281e)],
      ),
      borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
          child: Row(
            children: [
              const EivetLogo(size: 68),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Veterinaria\nEIVET',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 21,
                        height: 1.02,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'PANEL VETERINARIO / ADMIN',
                      style: TextStyle(
                        color: Color(0xff8ef0bd),
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
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: labels.length,
            separatorBuilder: (_, __) => const SizedBox(height: 3),
            itemBuilder: (context, i) {
              final selected = index == i;
              return Material(
                color: selected ? const Color(0xff078c5a) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icons[i],
                          size: 20,
                          color: selected
                              ? Colors.white
                              : const Color(0xffc1d7ce),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xffedf5f1),
                              fontSize: 14,
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .07),
            border: const Border(top: BorderSide(color: Colors.white24)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xff078c5a),
                    radius: 21,
                    child: Text(
                      name.isEmpty ? 'E' : name.trim()[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xffc1d7ce),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xffc1d7ce)),
                ],
              ),
              const SizedBox(height: 11),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, size: 17),
                  label: const Text('Salir'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xffff7777),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
