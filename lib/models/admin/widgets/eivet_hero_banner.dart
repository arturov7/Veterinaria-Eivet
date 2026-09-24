import 'package:flutter/material.dart';
import '../utils/admin_theme.dart';

/// Colorido banner clínico compartido por las pantallas del panel web.
class EivetHeroBanner extends StatelessWidget {
  const EivetHeroBanner({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
    this.actions,
    this.icon = Icons.pets_outlined,
    this.accent = AdminTheme.emerald,
    this.compact = false,
  });

  final String kicker, title, subtitle;
  final Widget? actions;
  final IconData icon;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 700;
      final iconSize = narrow ? 88.0 : 164.0;
      return Container(
        constraints: BoxConstraints(
          minHeight: compact
              ? 142
              : narrow
              ? 174
              : 190,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0, .53, 1],
            colors: [Color(0xfff0fbf5), Color(0xffc4ead7), Color(0xff064330)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffc9e4d5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120f382a),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: narrow ? 8 : 28,
              bottom: -20,
              child: Icon(
                Icons.pets,
                size: iconSize,
                color: Colors.white.withValues(alpha: .14),
              ),
            ),
            Positioned(
              right: narrow ? 40 : 105,
              top: -24,
              child: Icon(
                Icons.pets_outlined,
                size: narrow ? 40 : 70,
                color: AdminTheme.forest.withValues(alpha: .08),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(narrow ? 17 : 23),
              child: Row(
                children: [
                  Expanded(
                    flex: narrow ? 10 : 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AdminTheme.forest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            kicker.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: .7,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AdminTheme.forest,
                                fontSize: narrow ? 21 : 29,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AdminTheme.ink.withValues(alpha: .78),
                            fontSize: narrow ? 11 : 13,
                            height: 1.35,
                          ),
                        ),
                        if (actions != null) ...[
                          const SizedBox(height: 12),
                          actions!,
                        ],
                      ],
                    ),
                  ),
                  if (!narrow)
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: compact ? 150 : 220,
                        child: Image.asset(
                          'assets/eivet_pets_hero.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  if (!narrow)
                    SizedBox(
                      width: constraints.maxWidth * .11,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 38,
                            color: accent == AdminTheme.emerald
                                ? const Color(0xffffd66e)
                                : accent,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ciencia, compasión y vida',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
