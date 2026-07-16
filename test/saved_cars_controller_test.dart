import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/features/cars/data/local_car_catalog.dart';
import 'package:carnation/features/saved/application/saved_cars_controller.dart';

void main() {
  group('SavedCarsController', () {
    late SavedCarsController controller;

    setUp(() {
      controller = SavedCarsController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('saves a vehicle and exposes the saved count', () {
      expect(controller.save(localCarCatalog.first), isTrue);

      expect(controller.count, 1);
      expect(controller.cars.single, localCarCatalog.first);
    });

    test('prevents duplicate saved vehicles', () {
      expect(controller.save(localCarCatalog.first), isTrue);
      expect(controller.save(localCarCatalog.first), isFalse);

      expect(controller.count, 1);
    });

    test('removes a saved vehicle', () {
      controller.save(localCarCatalog.first);

      expect(controller.remove(localCarCatalog.first.id), isTrue);
      expect(controller.remove(localCarCatalog.first.id), isFalse);
      expect(controller.isEmpty, isTrue);
    });

    test('clears all saved vehicles', () {
      controller
        ..save(localCarCatalog[0])
        ..save(localCarCatalog[1])
        ..clear();

      expect(controller.isEmpty, isTrue);
      expect(controller.count, 0);
    });
  });
}
