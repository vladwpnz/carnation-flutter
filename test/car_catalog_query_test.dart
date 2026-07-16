import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/features/cars/data/local_car_catalog.dart';
import 'package:carnation/features/cars/domain/car_catalog_query.dart';

void main() {
  group('localCarCatalog', () {
    test('preserves the initial four vehicles with integer prices', () {
      expect(
        localCarCatalog.map((car) => car.fullName),
        containsAll([
          'BMW M4 2014',
          'Volkswagen Golf GTI 2014',
          'Ford Focus 2015',
          'Audi A6 2011',
        ]),
      );
      expect(localCarCatalog, hasLength(4));
      expect(localCarCatalog.map((car) => car.price), everyElement(isA<int>()));
    });
  });

  group('applyCarCatalogueQuery', () {
    test('searches brand, model, full name, and description case-insensitively',
        () {
      final results = applyCarCatalogueQuery(
        localCarCatalog,
        filters: const CarCatalogueFilters(searchQuery: 'tdci'),
      );

      expect(results.map((car) => car.fullName), ['Ford Focus 2015']);
    });

    test('filters by brand and body type', () {
      final results = applyCarCatalogueQuery(
        localCarCatalog,
        filters: const CarCatalogueFilters(
          brand: 'Volkswagen',
          bodyType: 'Hatchback',
        ),
      );

      expect(results.map((car) => car.fullName), [
        'Volkswagen Golf GTI 2014',
      ]);
    });

    test('sorts vehicles by price from low to high', () {
      final results = applyCarCatalogueQuery(
        localCarCatalog,
        sortOption: CarSortOption.priceLowToHigh,
      );

      expect(results.map((car) => car.price), [8500, 18900, 19000, 123000]);
    });

    test('returns an empty list when no vehicle matches', () {
      final results = applyCarCatalogueQuery(
        localCarCatalog,
        filters: const CarCatalogueFilters(searchQuery: 'convertible'),
      );

      expect(results, isEmpty);
    });
  });
}
