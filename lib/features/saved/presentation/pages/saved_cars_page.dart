import 'package:flutter/material.dart';
import 'package:motor_show/core/navigation/carnation_route.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';
import 'package:motor_show/features/cars/domain/car.dart';
import 'package:motor_show/features/cars/presentation/pages/car_details_page.dart';
import 'package:motor_show/features/cars/presentation/widgets/car_catalog_card.dart';
import 'package:motor_show/features/compare/application/comparison_controller.dart';
import 'package:motor_show/features/saved/application/saved_cars_controller.dart';

class SavedCarsPage extends StatelessWidget {
  final SavedCarsController savedCarsController;
  final ComparisonController comparisonController;

  const SavedCarsPage({
    super.key,
    required this.savedCarsController,
    required this.comparisonController,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: Scaffold(
        appBar: AppBar(title: const Text('Saved cars')),
        body: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: savedCarsController,
            builder: (context, _) {
              return AnimatedBuilder(
                animation: comparisonController,
                builder: (context, _) {
                  final cars = savedCarsController.cars;
                  if (cars.isEmpty) {
                    return _EmptySavedCars(
                      onBack: () => Navigator.maybePop(context),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _savedCountLabel(cars.length),
                                style: const TextStyle(
                                  color: CarNationColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),
                              for (final car in cars) ...[
                                CarCatalogCard(
                                  car: car,
                                  isSaved: true,
                                  isCompared:
                                      comparisonController.contains(car.id),
                                  onToggleSaved: () =>
                                      savedCarsController.remove(car.id),
                                  onToggleComparison: () =>
                                      _toggleComparison(context, car),
                                  onViewDetails: () =>
                                      _openCarDetails(context, car),
                                ),
                                const SizedBox(height: 14),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _savedCountLabel(int count) {
    return count == 1 ? '1 saved vehicle' : '$count saved vehicles';
  }

  void _openCarDetails(BuildContext context, Car car) {
    Navigator.of(context).push(
      carNationRoute<void>(
        builder: (_) => CarDetailsPage(
          car: car,
          savedCarsController: savedCarsController,
          comparisonController: comparisonController,
        ),
      ),
    );
  }

  void _toggleComparison(BuildContext context, Car car) {
    final result = comparisonController.toggle(car);
    final message = switch (result) {
      ComparisonToggleResult.added => '${car.fullName} added to comparison.',
      ComparisonToggleResult.removed =>
        '${car.fullName} removed from comparison.',
      ComparisonToggleResult.limitReached =>
        'You can compare up to ${ComparisonController.maxVehicles} vehicles.',
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmptySavedCars extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptySavedCars({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 72),
        const Icon(
          Icons.favorite_outline_rounded,
          color: CarNationColors.accentSoft,
          size: 64,
        ),
        const SizedBox(height: 20),
        const Text(
          'No saved cars yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CarNationColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Save vehicles from the catalogue to keep them within easy reach.',
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
