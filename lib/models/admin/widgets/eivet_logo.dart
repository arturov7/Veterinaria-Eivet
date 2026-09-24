import 'package:flutter/material.dart';

/// Sello oficial de Veterinaria EIVET, disponible como recurso local.
class EivetLogo extends StatelessWidget {
  const EivetLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: const Color(0xff003b2c),
        alignment: Alignment.center,
        child: Icon(
          Icons.pets,
          color: const Color(0xff93f3bb),
          size: size * .55,
        ),
      ),
    ),
  );
}
