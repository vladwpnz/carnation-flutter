import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/cars/domain/car_catalog_query.dart';

Future<CarCatalogueFilters?> showCarFiltersSheet({
  required BuildContext context,
  required CarCatalogueFilters initialFilters,
  required List<String> brands,
  required List<String> bodyTypes,
  required List<String> fuelTypes,
}) {
  return showModalBottomSheet<CarCatalogueFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CarFiltersSheet(
      initialFilters: initialFilters,
      brands: brands,
      bodyTypes: bodyTypes,
      fuelTypes: fuelTypes,
    ),
  );
}

class CarFiltersSheet extends StatefulWidget {
  final CarCatalogueFilters initialFilters;
  final List<String> brands;
  final List<String> bodyTypes;
  final List<String> fuelTypes;

  const CarFiltersSheet({
    super.key,
    required this.initialFilters,
    required this.brands,
    required this.bodyTypes,
    required this.fuelTypes,
  });

  @override
  State<CarFiltersSheet> createState() => _CarFiltersSheetState();
}

class _CarFiltersSheetState extends State<CarFiltersSheet> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  String? _draftBrand;
  String? _draftBodyType;
  String? _draftFuelType;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _draftBrand = filters.brand;
    _draftBodyType = filters.bodyType;
    _draftFuelType = filters.fuelType;
    _minPriceController = TextEditingController(
      text: filters.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: filters.maxPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: CarNationColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CarNationColors.textSecondary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filters',
                          style: TextStyle(
                            color: CarNationColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _FilterDropdown(
                    label: 'Brand',
                    value: _draftBrand,
                    values: widget.brands,
                    onChanged: (value) {
                      setState(() {
                        _draftBrand = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _FilterDropdown(
                    label: 'Body type',
                    value: _draftBodyType,
                    values: widget.bodyTypes,
                    onChanged: (value) {
                      setState(() {
                        _draftBodyType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _FilterDropdown(
                    label: 'Fuel type',
                    value: _draftFuelType,
                    values: widget.fuelTypes,
                    onChanged: (value) {
                      setState(() {
                        _draftFuelType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  _PriceFields(
                    minController: _minPriceController,
                    maxController: _maxPriceController,
                    errorText: _priceError,
                    onChanged: _clearPriceError,
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _reset,
                        child: const Text('Reset filters'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: _apply,
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearPriceError() {
    if (_priceError != null) {
      setState(() {
        _priceError = null;
      });
    }
  }

  void _reset() {
    setState(() {
      _draftBrand = null;
      _draftBodyType = null;
      _draftFuelType = null;
      _priceError = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _apply() {
    final minPrice = _parsePrice(_minPriceController.text);
    final maxPrice = _parsePrice(_maxPriceController.text);

    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      setState(() {
        _priceError = 'Minimum price cannot exceed maximum price.';
      });
      return;
    }

    Navigator.of(context).pop(
      CarCatalogueFilters(
        brand: _draftBrand,
        bodyType: _draftBodyType,
        fuelType: _draftFuelType,
        minPrice: minPrice,
        maxPrice: maxPrice,
      ),
    );
  }

  int? _parsePrice(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return int.tryParse(trimmed);
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(child: Text('Any')),
        for (final item in values)
          DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _PriceFields extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final String? errorText;
  final VoidCallback onChanged;

  const _PriceFields({
    required this.minController,
    required this.maxController,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price range',
          style: TextStyle(
            color: CarNationColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 420) {
              return Column(
                children: [
                  _PriceField(
                    controller: minController,
                    label: 'Minimum price',
                    onChanged: onChanged,
                  ),
                  const SizedBox(height: 10),
                  _PriceField(
                    controller: maxController,
                    label: 'Maximum price',
                    onChanged: onChanged,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _PriceField(
                    controller: minController,
                    label: 'Minimum price',
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PriceField(
                    controller: maxController,
                    label: 'Maximum price',
                    onChanged: onChanged,
                  ),
                ),
              ],
            );
          },
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: const TextStyle(
              color: CarNationColors.danger,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  const _PriceField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '\$',
        border: const OutlineInputBorder(),
      ),
    );
  }
}
