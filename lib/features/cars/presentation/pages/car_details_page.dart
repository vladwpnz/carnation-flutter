import 'package:flutter/material.dart';
import 'package:carnation/core/navigation/carnation_route.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/cars/presentation/widgets/car_image.dart';
import 'package:carnation/features/compare/application/comparison_controller.dart';
import 'package:carnation/features/requests/presentation/pages/request_builder_page.dart';
import 'package:carnation/features/saved/application/saved_cars_controller.dart';

class CarDetailsPage extends StatelessWidget {
  final Car car;
  final SavedCarsController savedCarsController;
  final ComparisonController comparisonController;

  const CarDetailsPage({
    super.key,
    required this.car,
    required this.savedCarsController,
    required this.comparisonController,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: AnimatedBuilder(
        animation: savedCarsController,
        builder: (context, _) {
          return AnimatedBuilder(
            animation: comparisonController,
            builder: (context, _) {
              return Scaffold(
                appBar: AppBar(title: const Text('Vehicle details')),
                body: SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                image: true,
                                label: '${car.fullName} vehicle photo',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    CarNationRadii.page,
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 10,
                                    child: CarImage(
                                      imagePath: car.imagePath,
                                      brand: car.brand,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                car.fullName,
                                style: const TextStyle(
                                  color: CarNationColors.textPrimary,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  height: 1.12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                car.formattedPrice,
                                style: const TextStyle(
                                  color: CarNationColors.accentSoft,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                car.description,
                                style: const TextStyle(
                                  color: CarNationColors.textSecondary,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'Specifications',
                                style: TextStyle(
                                  color: CarNationColors.textPrimary,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildSpecifications(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: _buildBottomActions(context),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSpecifications() {
    final specifications = <_CarSpecification>[
      _CarSpecification(
        icon: Icons.calendar_today_rounded,
        label: 'Model year',
        value: car.year.toString(),
      ),
      _CarSpecification(
        icon: Icons.directions_car_filled_rounded,
        label: 'Body type',
        value: car.bodyType,
      ),
      _CarSpecification(
        icon: Icons.local_gas_station_rounded,
        label: 'Fuel type',
        value: car.fuelType,
      ),
      _CarSpecification(
        icon: Icons.settings_rounded,
        label: 'Transmission',
        value: car.transmission,
      ),
      _CarSpecification(
        icon: Icons.speed_rounded,
        label: 'Horsepower',
        value: '${car.horsepower} hp',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 360;
        final itemWidth = useTwoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final specification in specifications)
              SizedBox(
                width: itemWidth,
                child: _SpecificationTile(specification: specification),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final isSaved = savedCarsController.contains(car.id);
    final isCompared = comparisonController.contains(car.id);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: CarNationColors.surface,
          border: Border(top: BorderSide(color: CarNationColors.border)),
        ),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('save-from-details'),
                        onPressed: () => _toggleSaved(context),
                        icon: Icon(
                          isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                        ),
                        label: Text(isSaved ? 'Saved' : 'Save'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('compare-from-details'),
                        onPressed: () => _toggleComparison(context),
                        icon: const Icon(Icons.compare_arrows_rounded),
                        label: Text(isCompared ? 'Compared' : 'Compare'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('request-offer'),
                    onPressed: () => _openRequestBuilder(context),
                    icon: const Icon(Icons.request_quote_rounded),
                    label: const Text('Request an offer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSaved(BuildContext context) {
    final saved = savedCarsController.toggle(car);
    _showMessage(
      context,
      saved
          ? '${car.fullName} saved.'
          : '${car.fullName} removed from saved cars.',
    );
  }

  void _toggleComparison(BuildContext context) {
    final result = comparisonController.toggle(car);
    final message = switch (result) {
      ComparisonToggleResult.added => '${car.fullName} added to comparison.',
      ComparisonToggleResult.removed =>
        '${car.fullName} removed from comparison.',
      ComparisonToggleResult.limitReached =>
        'You can compare up to ${ComparisonController.maxVehicles} vehicles.',
    };
    _showMessage(context, message);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openRequestBuilder(BuildContext context) {
    Navigator.of(context).push(
      carNationRoute<void>(
        builder: (_) => RequestBuilderPage(car: car),
      ),
    );
  }
}

class _SpecificationTile extends StatelessWidget {
  final _CarSpecification specification;

  const _SpecificationTile({required this.specification});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${specification.label}: ${specification.value}',
      child: Container(
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CarNationColors.surface,
          borderRadius: BorderRadius.circular(CarNationRadii.card),
          border: Border.all(color: CarNationColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              specification.icon,
              color: CarNationColors.accentSoft,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    specification.label,
                    style: const TextStyle(
                      color: CarNationColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    specification.value,
                    style: const TextStyle(
                      color: CarNationColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarSpecification {
  final IconData icon;
  final String label;
  final String value;

  const _CarSpecification({
    required this.icon,
    required this.label,
    required this.value,
  });
}
