import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/compare/application/comparison_controller.dart';

class ComparePage extends StatelessWidget {
  final ComparisonController comparisonController;

  const ComparePage({
    super.key,
    required this.comparisonController,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: Scaffold(
        appBar: AppBar(title: const Text('Compare vehicles')),
        body: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: comparisonController,
            builder: (context, _) {
              final cars = comparisonController.cars;
              if (cars.isEmpty) {
                return _EmptyComparison(
                    onBack: () => Navigator.maybePop(context));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth - 32;
                  final cardWidth = cars.length == 1
                      ? math.min(availableWidth, 340.0)
                      : math.min(math.max(availableWidth * 0.76, 250.0), 300.0);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cars.length} of ${ComparisonController.maxVehicles} selected',
                          style: const TextStyle(
                            color: CarNationColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var index = 0;
                                  index < cars.length;
                                  index++) ...[
                                SizedBox(
                                  width: cardWidth,
                                  child: _ComparisonVehicleCard(
                                    car: cars[index],
                                    onRemove: () => comparisonController
                                        .remove(cars[index].id),
                                  ),
                                ),
                                if (index < cars.length - 1)
                                  const SizedBox(width: 12),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ComparisonVehicleCard extends StatelessWidget {
  final Car car;
  final VoidCallback onRemove;

  const _ComparisonVehicleCard({
    required this.car,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final specifications = <(String, String)>[
      ('Price', Car.formatPrice(car.price)),
      ('Model year', car.year.toString()),
      ('Body type', car.bodyType),
      ('Fuel type', car.fuelType),
      ('Transmission', car.transmission),
      ('Horsepower', '${car.horsepower} hp'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(CarNationRadii.control),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.asset(
                  car.imagePath,
                  fit: BoxFit.cover,
                  semanticLabel: '${car.fullName} vehicle photo',
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              car.fullName,
              style: const TextStyle(
                color: CarNationColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            for (final specification in specifications)
              _ComparisonRow(
                label: specification.$1,
                value: specification.$2,
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                label: const Text('Remove'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String value;

  const _ComparisonRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: CarNationColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: CarNationColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _EmptyComparison extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyComparison({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 72),
        const Icon(
          Icons.compare_arrows_rounded,
          color: CarNationColors.accentSoft,
          size: 64,
        ),
        const SizedBox(height: 20),
        const Text(
          'No vehicles to compare',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CarNationColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add up to three vehicles from the catalogue or vehicle details.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CarNationColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.directions_car_rounded),
          label: const Text('Return to catalogue'),
        ),
      ],
    );
  }
}
