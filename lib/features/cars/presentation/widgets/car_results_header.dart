import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/domain/car_catalog_query.dart';

class CarResultsHeader extends StatelessWidget {
  final int resultCount;
  final int activeFilterCount;
  final CarSortOption sortOption;
  final ValueChanged<CarSortOption> onSortChanged;

  const CarResultsHeader({
    super.key,
    required this.resultCount,
    required this.activeFilterCount,
    required this.sortOption,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _resultText(resultCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (activeFilterCount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '$activeFilterCount active ${activeFilterCount == 1 ? 'filter' : 'filters'}',
                  style: const TextStyle(
                    color: CarNationColors.accentSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<CarSortOption>(
          tooltip: 'Sort vehicles',
          initialValue: sortOption,
          onSelected: onSortChanged,
          itemBuilder: (context) {
            return CarSortOption.values.map((option) {
              return PopupMenuItem<CarSortOption>(
                value: option,
                child: Text(option.label),
              );
            }).toList();
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 178),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: CarNationColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CarNationColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sort_rounded,
                  color: CarNationColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    sortOption.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _resultText(int count) {
    if (count == 0) {
      return 'No vehicles found';
    }
    if (count == 1) {
      return '1 vehicle found';
    }
    return '$count vehicles found';
  }
}
