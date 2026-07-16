class AdditionalService {
  final String id;
  final String title;
  final String description;
  final int price;

  const AdditionalService({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  bool get isFree => price == 0;
}
