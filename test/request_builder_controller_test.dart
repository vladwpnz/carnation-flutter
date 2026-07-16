import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/features/cars/data/local_car_catalog.dart';
import 'package:carnation/features/requests/application/request_builder_controller.dart';
import 'package:carnation/features/requests/data/local_service_catalog.dart';

void main() {
  group('RequestBuilderController', () {
    late RequestBuilderController controller;

    setUp(() {
      controller = RequestBuilderController(
        basePrice: localCarCatalog.first.price,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('selects a service once', () {
      final service = localAdditionalServices.first;

      expect(controller.select(service), isTrue);
      expect(controller.select(service), isFalse);
      expect(controller.selectedServices, [service]);
    });

    test('unselects a service', () {
      final service = localAdditionalServices.first;
      controller.select(service);

      expect(controller.unselect(service.id), isTrue);
      expect(controller.unselect(service.id), isFalse);
      expect(controller.selectedServices, isEmpty);
    });

    test('calculates the services subtotal deterministically', () {
      controller
        ..select(localAdditionalServices[0])
        ..select(localAdditionalServices[1])
        ..select(localAdditionalServices[2]);

      expect(controller.servicesSubtotal, 600 + 350 + 1500);
    });

    test('adds services subtotal to the base vehicle price', () {
      controller
        ..select(localAdditionalServices[3])
        ..select(localAdditionalServices[4]);

      expect(
        controller.estimatedTotal,
        localCarCatalog.first.price + 2000 + 250,
      );
    });

    test('free services do not change the estimated total', () {
      controller
        ..select(localAdditionalServices[6])
        ..select(localAdditionalServices[7]);

      expect(controller.servicesSubtotal, 0);
      expect(controller.estimatedTotal, localCarCatalog.first.price);
    });

    test('local service catalogue contains the required eight options', () {
      expect(localAdditionalServices, hasLength(8));
      expect(
        localAdditionalServices.map((service) => service.price),
        [600, 350, 1500, 2000, 250, 200, 0, 0],
      );
    });
  });
}
