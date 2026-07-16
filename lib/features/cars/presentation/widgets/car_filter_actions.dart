import 'package:flutter/material.dart';

class CarFilterActions extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onOpenFilters;
  final VoidCallback onResetFilters;

  const CarFilterActions({
    super.key,
    required this.hasActiveFilters,
    required this.onOpenFilters,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onOpenFilters,
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Filters'),
        ),
        if (hasActiveFilters)
          OutlinedButton.icon(
            onPressed: onResetFilters,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF334155)),
            ),
          ),
      ],
    );
  }
}
