import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/features/requests/data/vehicle_request_firestore_mapper.dart';
import 'package:carnation/features/requests/data/vehicle_request_repository.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';

import 'helpers/fake_vehicle_request_repository.dart';

void main() {
  group('VehicleRequestStatus', () {
    test('maps every status to and from its stable Firestore value', () {
      for (final status in VehicleRequestStatus.values) {
        expect(
          VehicleRequestStatus.fromFirestore(status.firestoreValue),
          status,
        );
      }
    });

    test('falls back safely for invalid stored values', () {
      expect(
        VehicleRequestStatus.fromFirestore('unexpected'),
        VehicleRequestStatus.submitted,
      );
      expect(
        VehicleRequestStatus.fromFirestore(null),
        VehicleRequestStatus.submitted,
      );
    });
  });

  group('VehicleRequest Firestore parsing', () {
    test('supports Timestamp and null server timestamp values', () {
      final createdAt = DateTime.utc(2026, 7, 16, 9, 30);
      final request = VehicleRequestFirestoreMapper.fromFirestore(
        id: 'request-1',
        data: _validData(
          createdAt: Timestamp.fromDate(createdAt),
          updatedAt: null,
        ),
      );

      expect(request.createdAt, createdAt);
      expect(request.updatedAt, isNull);
    });

    test('parses numeric values defensively', () {
      final request = VehicleRequest.fromMap(
        id: 'request-2',
        data: _validData(
          car: {
            'id': 'car-1',
            'displayName': 'BMW M4 2014',
            'modelYear': '2014',
            'imageAssetPath': 'assets/car1.jpg',
            'basePrice': 62000.9,
          },
          servicesSubtotal: '450',
          estimatedTotal: -20,
        ),
      );

      expect(request.car.modelYear, 2014);
      expect(request.car.basePrice, 62000);
      expect(request.servicesSubtotal, 450);
      expect(request.estimatedTotal, 0);
    });

    test('parses valid service snapshots and skips malformed entries', () {
      final request = VehicleRequest.fromMap(
        id: 'request-3',
        data: _validData(
          services: [
            {'id': 'inspection', 'title': 'Inspection', 'price': '450'},
            {'id': '', 'title': 'Missing ID', 'price': 10},
            'not-a-map',
            null,
          ],
        ),
      );

      expect(request.selectedServices, hasLength(1));
      expect(request.selectedServices.single.id, 'inspection');
      expect(request.selectedServices.single.price, 450);
    });

    test('malformed optional data never crashes parsing', () {
      final request = VehicleRequest.fromMap(
        id: 'request-4',
        data: {
          'car': 'invalid',
          'services': {'unexpected': true},
          'createdAt': Object(),
          'updatedAt': 123,
        },
      );

      expect(request.car.displayName, 'Vehicle details unavailable');
      expect(request.selectedServices, isEmpty);
      expect(request.createdAt, isNull);
      expect(request.updatedAt, isNull);
    });
  });

  test('short request number is deterministic and uppercase', () {
    expect(shortVehicleRequestDisplayId('abCd1234xyz'), 'CN-ABCD1234');
    expect(shortVehicleRequestDisplayId('x1'), 'CN-X1');
    expect(shortVehicleRequestDisplayId(''), 'CN-PENDING');
  });

  test('newest-first comparator places pending timestamps last', () {
    final requests = [
      sampleVehicleRequest(
        id: 'older',
        createdAt: DateTime.utc(2026, 7, 15),
      ),
      sampleVehicleRequest(
        id: 'pending',
        timestampsPending: true,
      ),
      sampleVehicleRequest(
        id: 'newer',
        createdAt: DateTime.utc(2026, 7, 16),
      ),
    ]..sort(compareVehicleRequestsNewestFirst);

    expect(requests.map((request) => request.id), [
      'newer',
      'older',
      'pending',
    ]);
  });
}

Map<String, Object?> _validData({
  Object? createdAt = '2026-07-16T09:30:00Z',
  Object? updatedAt = '2026-07-16T09:30:00Z',
  Object? car,
  Object? services,
  Object? servicesSubtotal = 450,
  Object? estimatedTotal = 62450,
}) {
  return <String, Object?>{
    'userId': 'user-1',
    'contactEmail': 'driver@example.com',
    'car': car ??
        {
          'id': 'bmw-m4-2014',
          'displayName': 'BMW M4 2014',
          'modelYear': 2014,
          'imageAssetPath': 'assets/car1.jpg',
          'basePrice': 62000,
        },
    'services': services ??
        [
          {'id': 'inspection', 'title': 'Inspection', 'price': 450},
        ],
    'servicesSubtotal': servicesSubtotal,
    'estimatedTotal': estimatedTotal,
    'status': 'submitted',
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
