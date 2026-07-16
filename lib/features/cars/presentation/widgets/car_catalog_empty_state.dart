import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';

class CarCatalogEmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const CarCatalogEmptyState({
    super.key,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: CarNationColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CarNationColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CarNationColors.border,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: CarNationColors.accentSoft,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching vehicles',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try another search term or clear the active filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CarNationColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }
}
