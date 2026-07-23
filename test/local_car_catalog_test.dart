import 'package:carnation/features/cars/data/catalog/audi_cars.dart';
import 'package:carnation/features/cars/data/catalog/bmw_cars.dart';
import 'package:carnation/features/cars/data/catalog/ford_cars.dart';
import 'package:carnation/features/cars/data/catalog/volkswagen_cars.dart';
import 'package:carnation/features/cars/data/local_car_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('local vehicle catalogue', () {
    test('contains exactly ten cars per brand and forty total', () {
      expect(bmwCars, hasLength(10));
      expect(volkswagenCars, hasLength(10));
      expect(fordCars, hasLength(10));
      expect(audiCars, hasLength(10));
      expect(localCarCatalog, hasLength(40));

      for (final brand in ['BMW', 'Volkswagen', 'Ford', 'Audi']) {
        expect(
          localCarCatalog.where((car) => car.brand == brand),
          hasLength(10),
        );
      }
    });

    test('uses unique lowercase kebab-case IDs', () {
      final ids = localCarCatalog.map((car) => car.id).toList();

      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, everyElement(matches(RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$'))));
    });

    test('provides valid required vehicle data', () {
      for (final car in localCarCatalog) {
        expect(car.brand.trim(), isNotEmpty);
        expect(car.model.trim(), isNotEmpty);
        expect(car.description.trim(), isNotEmpty);
        expect(car.imagePath.trim(), isNotEmpty);
        expect(car.bodyType.trim(), isNotEmpty);
        expect(car.fuelType.trim(), isNotEmpty);
        expect(car.transmission.trim(), isNotEmpty);
        expect(car.price, greaterThan(0));
        expect(car.horsepower, greaterThan(0));
        expect(car.year, inInclusiveRange(1900, DateTime.now().year + 1));
      }
    });

    test('uses unique WebP paths in the correct brand directories', () {
      final imagePaths = localCarCatalog.map((car) => car.imagePath).toList();

      expect(imagePaths.toSet(), hasLength(imagePaths.length));
      for (final car in localCarCatalog) {
        final brandDirectory = car.brand.toLowerCase();
        expect(
          car.imagePath,
          matches(
            RegExp(
              '^assets/cars/$brandDirectory/[a-z0-9]+(?:-[a-z0-9]+)*[.]webp\$',
            ),
          ),
        );
      }
    });

    test('retains the four original vehicles', () {
      expect(
        localCarCatalog.map((car) => car.id),
        containsAll([
          'bmw-m4-2014',
          'volkswagen-golf-gti-2014',
          'ford-focus-2015',
          'audi-a6-2011',
        ]),
      );
    });

    test('marks every electric vehicle with the Electric fuel type', () {
      const electricIds = {
        'bmw-i4-2023',
        'volkswagen-id3-2022',
        'volkswagen-id4-2023',
        'ford-mustang-mach-e-2022',
        'audi-e-tron-gt-2022',
      };

      for (final car in localCarCatalog.where(
        (car) => electricIds.contains(car.id),
      )) {
        expect(car.fuelType, 'Electric');
      }
    });
  });
}
