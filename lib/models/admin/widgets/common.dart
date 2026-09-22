import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pets_outlined, size: 48),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    ),
  );
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext c) =>
      const Center(child: CircularProgressIndicator());
}

Future<bool> confirmDelete(BuildContext c, String label) async =>
    (await showDialog<bool>(
      context: c,
      builder: (c) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar $label? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    )) ??
    false;
