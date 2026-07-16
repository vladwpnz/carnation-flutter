import 'dart:async';

import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/requests/data/vehicle_request_repository.dart';
import 'package:carnation/features/requests/domain/additional_service.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';

const sampleCar = Car(
  id: 'bmw-m4-2014',
  brand: 'BMW',
  model: 'M4',
  year: 2014,
  price: 62000,
  description: 'Performance coupe',
  imagePath: 'assets/car1.jpg',
  bodyType: 'Coupe',
  fuelType: 'Petrol',
  transmission: 'Automatic',
  horsepower: 425,
);

const sampleService = AdditionalService(
  id: 'inspection',
  title: 'Pre-purchase inspection',
  description: 'Independent vehicle inspection.',
  price: 450,
);

VehicleRequest sampleVehicleRequest({
  String id = 'abc12345document',
  VehicleRequestStatus status = VehicleRequestStatus.submitted,
  DateTime? createdAt,
  bool timestampsPending = false,
  List<VehicleRequestServiceSnapshot>? services,
}) {
  final selectedServices = services ??
      const <VehicleRequestServiceSnapshot>[
        VehicleRequestServiceSnapshot(
          id: 'inspection',
          title: 'Pre-purchase inspection',
          price: 450,
        ),
      ];

  return VehicleRequest(
    id: id,
    userId: 'user-1',
    contactEmail: 'driver@example.com',
    car: const VehicleRequestCarSnapshot(
      id: 'bmw-m4-2014',
      displayName: 'BMW M4 2014',
      modelYear: 2014,
      imageAssetPath: 'assets/car1.jpg',
      basePrice: 62000,
    ),
    selectedServices: selectedServices,
    servicesSubtotal: 450,
    estimatedTotal: 62450,
    status: status,
    createdAt: timestampsPending
        ? null
        : createdAt ?? DateTime.utc(2026, 7, 16, 10, 30),
    updatedAt: timestampsPending
        ? null
        : createdAt ?? DateTime.utc(2026, 7, 16, 10, 30),
  );
}

class FakeVehicleRequestRepository implements VehicleRequestRepository {
  final StreamController<List<VehicleRequest>> _requestsController =
      StreamController<List<VehicleRequest>>.broadcast();

  List<VehicleRequest> _requests;
  String createdRequestId;
  Object? createError;
  Object? cancellationError;
  Completer<String>? createCompleter;
  Completer<void>? cancellationCompleter;
  int createCallCount = 0;
  int cancellationCallCount = 0;

  @override
  AuthenticatedRequestUser? currentUser;

  FakeVehicleRequestRepository({
    List<VehicleRequest> requests = const <VehicleRequest>[],
    this.createdRequestId = 'abc12345document',
    this.currentUser = const AuthenticatedRequestUser(
      id: 'user-1',
      email: 'driver@example.com',
    ),
  }) : _requests = List<VehicleRequest>.of(requests);

  @override
  Future<String> createRequest({
    required Car car,
    required List<AdditionalService> selectedServices,
    required int servicesSubtotal,
    required int estimatedTotal,
  }) async {
    createCallCount += 1;
    if (createError case final error?) {
      throw error;
    }
    if (createCompleter case final completer?) {
      return completer.future;
    }
    return createdRequestId;
  }

  @override
  Stream<List<VehicleRequest>> watchUserRequests() async* {
    yield List<VehicleRequest>.unmodifiable(_requests);
    yield* _requestsController.stream;
  }

  @override
  Stream<VehicleRequest?> watchRequestById(String requestId) {
    return watchUserRequests().map(
      (requests) => _findRequest(requests, requestId),
    );
  }

  @override
  Future<void> cancelSubmittedRequest(String requestId) async {
    cancellationCallCount += 1;
    if (cancellationError case final error?) {
      throw error;
    }
    if (cancellationCompleter case final completer?) {
      await completer.future;
    }

    final request = _findRequest(_requests, requestId);
    if (request == null) {
      throw const VehicleRequestRepositoryException(
        code: 'request-not-found',
        message: 'The request could not be found.',
      );
    }
    if (request.status != VehicleRequestStatus.submitted) {
      throw const VehicleRequestRepositoryException(
        code: 'request-not-cancellable',
        message: 'Only requests with Submitted status can be cancelled.',
      );
    }

    final updated = VehicleRequest(
      id: request.id,
      userId: request.userId,
      contactEmail: request.contactEmail,
      car: request.car,
      selectedServices: request.selectedServices,
      servicesSubtotal: request.servicesSubtotal,
      estimatedTotal: request.estimatedTotal,
      status: VehicleRequestStatus.cancelled,
      createdAt: request.createdAt,
      updatedAt: DateTime.utc(2026, 7, 16, 11),
    );
    setRequests([
      for (final existing in _requests)
        if (existing.id == requestId) updated else existing,
    ]);
  }

  void setRequests(List<VehicleRequest> requests) {
    _requests = List<VehicleRequest>.of(requests);
    _requestsController.add(List<VehicleRequest>.unmodifiable(_requests));
  }

  Future<void> dispose() => _requestsController.close();

  VehicleRequest? _findRequest(
    List<VehicleRequest> requests,
    String requestId,
  ) {
    for (final request in requests) {
      if (request.id == requestId) {
        return request;
      }
    }
    return null;
  }
}
