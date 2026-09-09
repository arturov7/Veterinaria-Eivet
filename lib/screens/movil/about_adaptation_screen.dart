import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/movil/veterinary_catalog_repository.dart';

class AboutAdaptationScreen extends StatelessWidget {
  const AboutAdaptationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = context
        .watch<VeterinaryCatalogRepository>()
        .projectFeatures;
    return Scaffold(
      appBar: AppBar(title: const Text('EIVET · Proyecto académico')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: features.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Aplicación móvil para clientes de la Veterinaria EIVET.',
                style: TextStyle(fontSize: 17),
              ),
            );
          }
          final feature = features[index - 1];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE5F2E9),
                child: Icon(feature.icon, color: const Color(0xFF003F35)),
              ),
              title: Text(
                feature.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(feature.detail),
            ),
          );
        },
      ),
    );
  }
}
