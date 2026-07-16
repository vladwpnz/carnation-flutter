class Car {
  final String id;
  final String brand;
  final String model;
  final int year;
  final int price;
  final String description;
  final String imagePath;
  final String bodyType;
  final String fuelType;
  final String transmission;
  final int horsepower;

  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.bodyType,
    required this.fuelType,
    required this.transmission,
    required this.horsepower,
  });

  String get fullName => '$brand $model $year';

  String get formattedPrice => 'Price: ${formatPrice(price)}';

  static String formatPrice(int value) => '\$${_formatPrice(value)}';

  static String _formatPrice(int value) {
    final source = value.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < source.length; index += 1) {
      if (index > 0 && (source.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(source[index]);
    }

    return buffer.toString();
  }
}
