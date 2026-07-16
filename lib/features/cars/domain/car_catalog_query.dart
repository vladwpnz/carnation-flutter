import 'package:carnation/features/cars/domain/car.dart';

enum CarSortOption {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  yearNewestFirst,
  yearOldestFirst,
}

extension CarSortOptionLabel on CarSortOption {
  String get label {
    switch (this) {
      case CarSortOption.recommended:
        return 'Recommended';
      case CarSortOption.priceLowToHigh:
        return 'Price: low to high';
      case CarSortOption.priceHighToLow:
        return 'Price: high to low';
      case CarSortOption.yearNewestFirst:
        return 'Year: newest first';
      case CarSortOption.yearOldestFirst:
        return 'Year: oldest first';
    }
  }
}

class CarCatalogueFilters {
  final String searchQuery;
  final String? brand;
  final String? bodyType;
  final String? fuelType;
  final int? minPrice;
  final int? maxPrice;

  const CarCatalogueFilters({
    this.searchQuery = '',
    this.brand,
    this.bodyType,
    this.fuelType,
    this.minPrice,
    this.maxPrice,
  });

  bool get hasActiveFilters {
    return brand != null ||
        bodyType != null ||
        fuelType != null ||
        minPrice != null ||
        maxPrice != null;
  }
}

List<Car> applyCarCatalogueQuery(
  List<Car> cars, {
  CarCatalogueFilters filters = const CarCatalogueFilters(),
  CarSortOption sortOption = CarSortOption.recommended,
}) {
  final normalizedQuery = filters.searchQuery.trim().toLowerCase();
  final results = cars.where((car) {
    if (normalizedQuery.isNotEmpty && !_matchesSearch(car, normalizedQuery)) {
      return false;
    }

    if (filters.brand != null && car.brand != filters.brand) {
      return false;
    }

    if (filters.bodyType != null && car.bodyType != filters.bodyType) {
      return false;
    }

    if (filters.fuelType != null && car.fuelType != filters.fuelType) {
      return false;
    }

    if (filters.minPrice != null && car.price < filters.minPrice!) {
      return false;
    }

    if (filters.maxPrice != null && car.price > filters.maxPrice!) {
      return false;
    }

    return true;
  }).toList();

  switch (sortOption) {
    case CarSortOption.recommended:
      return results;
    case CarSortOption.priceLowToHigh:
      results.sort((a, b) => a.price.compareTo(b.price));
      return results;
    case CarSortOption.priceHighToLow:
      results.sort((a, b) => b.price.compareTo(a.price));
      return results;
    case CarSortOption.yearNewestFirst:
      results.sort((a, b) => b.year.compareTo(a.year));
      return results;
    case CarSortOption.yearOldestFirst:
      results.sort((a, b) => a.year.compareTo(b.year));
      return results;
  }
}

bool _matchesSearch(Car car, String normalizedQuery) {
  return car.brand.toLowerCase().contains(normalizedQuery) ||
      car.model.toLowerCase().contains(normalizedQuery) ||
      car.fullName.toLowerCase().contains(normalizedQuery) ||
      car.description.toLowerCase().contains(normalizedQuery);
}
