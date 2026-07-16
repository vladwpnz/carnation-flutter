import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/requests/domain/additional_service.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';

abstract final class VehicleRequestFields {
  static const userId = 'userId';
  static const contactEmail = 'contactEmail';
  static const car = 'car';
  static const services = 'services';
  static const servicesSubtotal = 'servicesSubtotal';
  static const estimatedTotal = 'estimatedTotal';
  static const status = 'status';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}

abstract final class VehicleRequestCarFields {
  static const id = 'id';
  static const displayName = 'displayName';
  static const modelYear = 'modelYear';
  static const imageAssetPath = 'imageAssetPath';
  static const basePrice = 'basePrice';
}

abstract final class VehicleRequestServiceFields {
  static const id = 'id';
  static const title = 'title';
  static const price = 'price';
}

abstract final class VehicleRequestFirestoreMapper {
  static Map<String, Object?> createData({
    required String userId,
    required String contactEmail,
    required Car car,
    required List<AdditionalService> selectedServices,
    required int servicesSubtotal,
    required int estimatedTotal,
  }) {
    return <String, Object?>{
      VehicleRequestFields.userId: userId,
      VehicleRequestFields.contactEmail: contactEmail,
      VehicleRequestFields.car: <String, Object?>{
        VehicleRequestCarFields.id: car.id,
        VehicleRequestCarFields.displayName: car.fullName,
        VehicleRequestCarFields.modelYear: car.year,
        VehicleRequestCarFields.imageAssetPath: car.imagePath,
        VehicleRequestCarFields.basePrice: car.price,
      },
      VehicleRequestFields.services: selectedServices
          .map(
            (service) => <String, Object?>{
              VehicleRequestServiceFields.id: service.id,
              VehicleRequestServiceFields.title: service.title,
              VehicleRequestServiceFields.price: service.price,
            },
          )
          .toList(growable: false),
      VehicleRequestFields.servicesSubtotal: servicesSubtotal,
      VehicleRequestFields.estimatedTotal: estimatedTotal,
      VehicleRequestFields.status:
          VehicleRequestStatus.submitted.firestoreValue,
      VehicleRequestFields.createdAt: FieldValue.serverTimestamp(),
      VehicleRequestFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  static VehicleRequest fromFirestore({
    required String id,
    required Object? data,
  }) {
    return VehicleRequest.fromMap(
      id: id,
      data: _normalizeFirestoreValues(data),
    );
  }

  static Object? _normalizeFirestoreValues(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }

    if (value is Map) {
      return <Object?, Object?>{
        for (final entry in value.entries)
          entry.key: _normalizeFirestoreValues(entry.value),
      };
    }

    if (value is Iterable) {
      return value.map(_normalizeFirestoreValues).toList(growable: false);
    }

    return value;
  }
}
