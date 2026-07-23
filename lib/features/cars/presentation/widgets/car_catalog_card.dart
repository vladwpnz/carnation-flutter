import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/cars/presentation/widgets/car_image.dart';

class CarCatalogCard extends StatelessWidget {
  final Car car;
  final bool isSaved;
  final bool isCompared;
  final VoidCallback onToggleSaved;
  final VoidCallback onToggleComparison;
  final VoidCallback onViewDetails;

  const CarCatalogCard({
    super.key,
    required this.car,
    required this.isSaved,
    required this.isCompared,
    required this.onToggleSaved,
    required this.onToggleComparison,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: CarImage(
                      imagePath: car.imagePath,
                      brand: car.brand,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      _ImageAction(
                        key: Key('save-car-${car.id}'),
                        tooltip: isSaved ? 'Remove from saved' : 'Save vehicle',
                        selected: isSaved,
                        icon: isSaved
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        onPressed: onToggleSaved,
                      ),
                      const SizedBox(width: 6),
                      _ImageAction(
                        key: Key('compare-car-${car.id}'),
                        tooltip: isCompared
                            ? 'Remove from comparison'
                            : 'Add to comparison',
                        selected: isCompared,
                        icon: Icons.compare_arrows_rounded,
                        onPressed: onToggleComparison,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              car.fullName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CarNationColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              car.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CarNationColors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(label: car.bodyType),
                _MetaChip(label: car.fuelType),
                _MetaChip(label: car.transmission),
                _MetaChip(label: '${car.horsepower} hp'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    car.formattedPrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CarNationColors.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  key: Key('view-details-${car.id}'),
                  onPressed: onViewDetails,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('View details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageAction extends StatelessWidget {
  final String tooltip;
  final bool selected;
  final IconData icon;
  final VoidCallback onPressed;

  const _ImageAction({
    super.key,
    required this.tooltip,
    required this.selected,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: tooltip,
      child: Material(
        color: selected
            ? CarNationColors.accent
            : CarNationColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(CarNationRadii.control),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: CarNationColors.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CarNationColors.accentSoft,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
