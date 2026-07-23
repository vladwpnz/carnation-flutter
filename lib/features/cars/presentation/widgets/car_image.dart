import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';

const carImageFallbacksByBrand = <String, String>{
  'BMW': 'assets/car1.jpg',
  'Volkswagen': 'assets/car2.jpg',
  'Ford': 'assets/car3.jpg',
  'Audi': 'assets/car4.jpg',
};

String? carImageFallbackForBrand(String brand) {
  final normalizedBrand = brand.trim().toLowerCase();

  for (final entry in carImageFallbacksByBrand.entries) {
    if (entry.key.toLowerCase() == normalizedBrand) {
      return entry.value;
    }
  }

  return null;
}

String inferCarImageBrand({
  required String imagePath,
  String displayName = '',
}) {
  final normalizedPath = imagePath.trim().toLowerCase();
  final normalizedName = displayName.trim().toLowerCase();

  for (final brand in carImageFallbacksByBrand.keys) {
    final normalizedBrand = brand.toLowerCase();
    if (normalizedPath.contains('/$normalizedBrand/') ||
        normalizedName == normalizedBrand ||
        normalizedName.startsWith('$normalizedBrand ')) {
      return brand;
    }
  }

  return '';
}

class CarImage extends StatelessWidget {
  final String imagePath;
  final String brand;
  final BoxFit fit;
  final double? width;
  final double? height;
  final AlignmentGeometry alignment;
  final String? semanticLabel;

  const CarImage({
    super.key,
    required this.imagePath,
    required this.brand,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return _buildBrandFallback();
    }

    return Image.asset(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => _buildBrandFallback(),
    );
  }

  Widget _buildBrandFallback() {
    final fallbackPath = carImageFallbackForBrand(brand);

    if (fallbackPath == null || fallbackPath == imagePath) {
      return const _UnavailableCarImage();
    }

    return Image.asset(
      fallbackPath,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => const _UnavailableCarImage(),
    );
  }
}

class _UnavailableCarImage extends StatelessWidget {
  const _UnavailableCarImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: CarNationColors.surfaceRaised,
      child: Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 46,
          color: CarNationColors.textMuted,
        ),
      ),
    );
  }
}
