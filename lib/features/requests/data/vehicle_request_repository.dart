import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carnation/features/cars/domain/car.dart';
import 'package:carnation/features/requests/data/vehicle_request_firestore_mapper.dart';
import 'package:carnation/features/requests/domain/additional_service.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';

class AuthenticatedRequestUser {
  final String id;
  final String email;

  const AuthenticatedRequestUser({required this.id, required this.email});
}

class VehicleRequestRepositoryException implements Exception {
  final String code;
  final String message;
  final FirebaseException? cause;

  const VehicleRequestRepositoryException({
    required this.code,
    required this.message,
    this.cause,
  });

  factory VehicleRequestRepositoryException.fromFirebase(
    FirebaseException error,
  ) {
    final message = switch (error.code) {
      'permission-denied' =>
        'Request access is not available yet. Please try again after the Firestore rules are published.',
      'unavailable' ||
      'network-request-failed' =>
        'The request service is temporarily unavailable. Check your connection and try again.',
      'not-found' => 'The request could not be found.',
      'aborted' =>
        'The request changed while it was being updated. Please try again.',
      _ =>
        'The request service could not complete this action. Please try again.',
    };

    return VehicleRequestRepositoryException(
      code: error.code,
      message: message,
      cause: error,
    );
  }

  @override
  String toString() => message;
}

abstract interface class VehicleRequestRepository {
  AuthenticatedRequestUser? get currentUser;

  Future<String> createRequest({
    required Car car,
    required List<AdditionalService> selectedServices,
    required int servicesSubtotal,
    required int estimatedTotal,
  });

  Stream<List<VehicleRequest>> watchUserRequests();

  Stream<VehicleRequest?> watchRequestById(String requestId);

  Future<void> cancelSubmittedRequest(String requestId);
}

class FirestoreVehicleRequestRepository implements VehicleRequestRepository {
  static const collectionPath = 'requests';

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  const FirestoreVehicleRequestRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  @override
  AuthenticatedRequestUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    final email = user?.email?.trim() ?? '';

    if (user == null || email.isEmpty) {
      return null;
    }

    return AuthenticatedRequestUser(id: user.uid, email: email);
  }

  @override
  Future<String> createRequest({
    required Car car,
    required List<AdditionalService> selectedServices,
    required int servicesSubtotal,
    required int estimatedTotal,
  }) async {
    final user = _requireCurrentUser();
    final document = _database.collection(collectionPath).doc();
    final data = VehicleRequestFirestoreMapper.createData(
      userId: user.id,
      contactEmail: user.email,
      car: car,
      selectedServices: selectedServices,
      servicesSubtotal: servicesSubtotal,
      estimatedTotal: estimatedTotal,
    );

    try {
      await document.set(data);
      return document.id;
    } on FirebaseException catch (error) {
      throw VehicleRequestRepositoryException.fromFirebase(error);
    }
  }

  @override
  Stream<List<VehicleRequest>> watchUserRequests() async* {
    final user = _requireCurrentUser();
    final query = _database
        .collection(collectionPath)
        .where(VehicleRequestFields.userId, isEqualTo: user.id);

    try {
      await for (final snapshot in query.snapshots()) {
        final requests = snapshot.docs
            .map(
              (document) => VehicleRequestFirestoreMapper.fromFirestore(
                id: document.id,
                data: document.data(),
              ),
            )
            .toList();
        requests.sort(compareVehicleRequestsNewestFirst);
        yield List.unmodifiable(requests);
      }
    } on FirebaseException catch (error) {
      throw VehicleRequestRepositoryException.fromFirebase(error);
    }
  }

  @override
  Stream<VehicleRequest?> watchRequestById(String requestId) async* {
    final user = _requireCurrentUser();
    final normalizedId = requestId.trim();
    if (normalizedId.isEmpty) {
      throw const VehicleRequestRepositoryException(
        code: 'invalid-request-id',
        message: 'The request number is invalid.',
      );
    }

    final query = _database
        .collection(collectionPath)
        .where(VehicleRequestFields.userId, isEqualTo: user.id)
        .where(FieldPath.documentId, isEqualTo: normalizedId)
        .limit(1);

    try {
      await for (final snapshot in query.snapshots()) {
        if (snapshot.docs.isEmpty) {
          yield null;
          continue;
        }

        final document = snapshot.docs.single;
        yield VehicleRequestFirestoreMapper.fromFirestore(
          id: document.id,
          data: document.data(),
        );
      }
    } on FirebaseException catch (error) {
      throw VehicleRequestRepositoryException.fromFirebase(error);
    }
  }

  @override
  Future<void> cancelSubmittedRequest(String requestId) async {
    final user = _requireCurrentUser();
    final normalizedId = requestId.trim();
    if (normalizedId.isEmpty) {
      throw const VehicleRequestRepositoryException(
        code: 'invalid-request-id',
        message: 'The request number is invalid.',
      );
    }

    final reference = _database.collection(collectionPath).doc(normalizedId);

    try {
      await _database.runTransaction((transaction) async {
        final snapshot = await transaction.get(reference);
        final data = snapshot.data();

        if (!snapshot.exists || data == null) {
          throw const VehicleRequestRepositoryException(
            code: 'request-not-found',
            message: 'The request could not be found.',
          );
        }

        if (data[VehicleRequestFields.userId] != user.id) {
          throw const VehicleRequestRepositoryException(
            code: 'request-not-owned',
            message: 'You do not have access to this request.',
          );
        }

        if (data[VehicleRequestFields.status] !=
            VehicleRequestStatus.submitted.firestoreValue) {
          throw const VehicleRequestRepositoryException(
            code: 'request-not-cancellable',
            message: 'Only requests with Submitted status can be cancelled.',
          );
        }

        transaction.update(reference, <String, Object?>{
          VehicleRequestFields.status:
              VehicleRequestStatus.cancelled.firestoreValue,
          VehicleRequestFields.updatedAt: FieldValue.serverTimestamp(),
        });
      });
    } on VehicleRequestRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw VehicleRequestRepositoryException.fromFirebase(error);
    }
  }

  AuthenticatedRequestUser _requireCurrentUser() {
    final user = currentUser;
    if (user == null) {
      throw const VehicleRequestRepositoryException(
        code: 'authentication-required',
        message: 'Sign in with an email account to manage vehicle requests.',
      );
    }

    return user;
  }
}

int compareVehicleRequestsNewestFirst(
  VehicleRequest left,
  VehicleRequest right,
) {
  final leftDate = left.createdAt;
  final rightDate = right.createdAt;

  if (leftDate == null && rightDate == null) {
    return right.id.compareTo(left.id);
  }
  if (leftDate == null) {
    return 1;
  }
  if (rightDate == null) {
    return -1;
  }

  final dateOrder = rightDate.compareTo(leftDate);
  return dateOrder == 0 ? right.id.compareTo(left.id) : dateOrder;
}
