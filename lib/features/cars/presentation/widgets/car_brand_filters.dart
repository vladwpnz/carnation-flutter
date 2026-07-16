import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';

class CarBrandFilters extends StatelessWidget {
  final List<String> brands;
  final String? selectedBrand;
  final ValueChanged<String?> onSelected;

  const CarBrandFilters({
    super.key,
    required this.brands,
    required this.selectedBrand,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final brand = index == 0 ? null : brands[index - 1];
          final selected = selectedBrand == brand;

          return ChoiceChip(
            label: Text(brand ?? 'All'),
            selected: selected,
            onSelected: (_) => onSelected(brand),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected ? Colors.white : CarNationColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
            selectedColor: CarNationColors.accent,
            backgroundColor: CarNationColors.surface,
            side: BorderSide(
              color: selected ? CarNationColors.accent : CarNationColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}
