enum VehicleRequestStatus {
  submitted,
  underReview,
  customerContacted,
  offerPrepared,
  completed,
  cancelled;

  String get firestoreValue => switch (this) {
        VehicleRequestStatus.submitted => 'submitted',
        VehicleRequestStatus.underReview => 'underReview',
        VehicleRequestStatus.customerContacted => 'customerContacted',
        VehicleRequestStatus.offerPrepared => 'offerPrepared',
        VehicleRequestStatus.completed => 'completed',
        VehicleRequestStatus.cancelled => 'cancelled',
      };

  String get label => switch (this) {
        VehicleRequestStatus.submitted => 'Submitted',
        VehicleRequestStatus.underReview => 'Under review',
        VehicleRequestStatus.customerContacted => 'Customer contacted',
        VehicleRequestStatus.offerPrepared => 'Offer prepared',
        VehicleRequestStatus.completed => 'Completed',
        VehicleRequestStatus.cancelled => 'Cancelled',
      };

  static VehicleRequestStatus fromFirestore(Object? value) {
    return VehicleRequestStatus.values.firstWhere(
      (status) => status.firestoreValue == value,
      orElse: () => VehicleRequestStatus.submitted,
    );
  }
}

class VehicleRequestCarSnapshot {
  final String id;
  final String displayName;
  final int modelYear;
  final String imageAssetPath;
  final int basePrice;

  const VehicleRequestCarSnapshot({
    required this.id,
    required this.displayName,
    required this.modelYear,
    required this.imageAssetPath,
    required this.basePrice,
  });

  factory VehicleRequestCarSnapshot.fromMap(Object? value) {
    final map = _stringKeyedMap(value);

    return VehicleRequestCarSnapshot(
      id: _readString(map['id']),
      displayName: _readString(
        map['displayName'],
        fallback: 'Vehicle details unavailable',
      ),
      modelYear: _readInt(map['modelYear']),
      imageAssetPath: _readString(map['imageAssetPath']),
      basePrice: _readInt(map['basePrice']),
    );
  }
}

class VehicleRequestServiceSnapshot {
  final String id;
  final String title;
  final int price;

  const VehicleRequestServiceSnapshot({
    required this.id,
    required this.title,
    required this.price,
  });

  static VehicleRequestServiceSnapshot? tryFromMap(Object? value) {
    final map = _stringKeyedMap(value);
    final id = _readString(map['id']);
    final title = _readString(map['title']);

    if (id.isEmpty || title.isEmpty) {
      return null;
    }

    return VehicleRequestServiceSnapshot(
      id: id,
      title: title,
      price: _readInt(map['price']),
    );
  }
}

class VehicleRequest {
  final String id;
  final String userId;
  final String contactEmail;
  final VehicleRequestCarSnapshot car;
  final List<VehicleRequestServiceSnapshot> selectedServices;
  final int servicesSubtotal;
  final int estimatedTotal;
  final VehicleRequestStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleRequest({
    required this.id,
    required this.userId,
    required this.contactEmail,
    required this.car,
    required this.selectedServices,
    required this.servicesSubtotal,
    required this.estimatedTotal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleRequest.fromMap({
    required String id,
    required Object? data,
  }) {
    final map = _stringKeyedMap(data);
    final services = <VehicleRequestServiceSnapshot>[];
    final storedServices = map['services'];

    if (storedServices is Iterable) {
      for (final entry in storedServices) {
        final service = VehicleRequestServiceSnapshot.tryFromMap(entry);
        if (service != null) {
          services.add(service);
        }
      }
    }

    return VehicleRequest(
      id: id.trim(),
      userId: _readString(map['userId']),
      contactEmail: _readString(map['contactEmail']),
      car: VehicleRequestCarSnapshot.fromMap(map['car']),
      selectedServices: List.unmodifiable(services),
      servicesSubtotal: _readInt(map['servicesSubtotal']),
      estimatedTotal: _readInt(map['estimatedTotal']),
      status: VehicleRequestStatus.fromFirestore(map['status']),
      createdAt: _readDateTime(map['createdAt']),
      updatedAt: _readDateTime(map['updatedAt']),
    );
  }

  String get shortDisplayId => shortVehicleRequestDisplayId(id);
}

String shortVehicleRequestDisplayId(String requestId) {
  final normalized = requestId.trim().toUpperCase();
  if (normalized.isEmpty) {
    return 'CN-PENDING';
  }

  final visibleLength = normalized.length < 8 ? normalized.length : 8;
  return 'CN-${normalized.substring(0, visibleLength)}';
}

Map<String, Object?> _stringKeyedMap(Object? value) {
  if (value is! Map) {
    return const <String, Object?>{};
  }

  return <String, Object?>{
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}

String _readString(Object? value, {String fallback = ''}) {
  if (value is! String) {
    return fallback;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

int _readInt(Object? value) {
  if (value is num && value.isFinite) {
    final parsed = value.toInt();
    return parsed < 0 ? 0 : parsed;
  }

  if (value is String) {
    final parsed = num.tryParse(value.trim());
    if (parsed != null && parsed.isFinite) {
      final integer = parsed.toInt();
      return integer < 0 ? 0 : integer;
    }
  }

  return 0;
}

DateTime? _readDateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}
