import 'package:flutter_test/flutter_test.dart';
import 'package:motor_show/features/cars/data/local_car_catalog.dart';
import 'package:motor_show/features/compare/application/comparison_controller.dart';

void main() {
  group('ComparisonController', () {
    late ComparisonController controller;

    setUp(() {
      controller = ComparisonController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('adds a vehicle to comparison', () {
      expect(
        controller.add(localCarCatalog.first),
        ComparisonAddResult.added,
      );
      expect(controller.count, 1);
    });

    test('prevents duplicate comparison entries', () {
      controller.add(localCarCatalog.first);

      expect(
        controller.add(localCarCatalog.first),
        ComparisonAddResult.alreadySelected,
      );
      expect(controller.count, 1);
    });

    test('removes a vehicle from comparison', () {
      controller.add(localCarCatalog.first);

      expect(controller.remove(localCarCatalog.first.id), isTrue);
      expect(controller.remove(localCarCatalog.first.id), isFalse);
      expect(controller.isEmpty, isTrue);
    });

    test('limits comparison to three vehicles', () {
      for (final car in localCarCatalog.take(3)) {
        expect(controller.add(car), ComparisonAddResult.added);
      }

      expect(
        controller.add(localCarCatalog[3]),
        ComparisonAddResult.limitReached,
      );
      expect(controller.count, ComparisonController.maxVehicles);
      expect(controller.isFull, isTrue);
    });

    test('toggle reports limit reached without changing selection', () {
      for (final car in localCarCatalog.take(3)) {
        controller.add(car);
      }

      expect(
        controller.toggle(localCarCatalog[3]),
        ComparisonToggleResult.limitReached,
      );
      expect(controller.count, 3);
    });
  });
}
