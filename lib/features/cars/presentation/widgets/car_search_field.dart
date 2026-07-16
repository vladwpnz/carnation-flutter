import 'package:flutter/material.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';

class CarSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;

  const CarSearchField({
    super.key,
    required this.controller,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search brand, model, or description',
        hintStyle: const TextStyle(color: CarNationColors.textMuted),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: controller.clear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: CarNationColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: CarNationColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: CarNationColors.accent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
