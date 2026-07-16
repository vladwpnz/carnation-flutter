import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:motor_show/features/requests/domain/additional_service.dart';

class RequestBuilderController extends ChangeNotifier {
  final int basePrice;
  final Map<String, AdditionalService> _selectedById =
      <String, AdditionalService>{};

  RequestBuilderController({required this.basePrice});

  UnmodifiableListView<AdditionalService> get selectedServices {
    return UnmodifiableListView<AdditionalService>(_selectedById.values);
  }

  int get servicesSubtotal {
    return _selectedById.values.fold(0, (total, service) => total + service.price);
  }

  int get estimatedTotal => basePrice + servicesSubtotal;

  bool contains(String serviceId) => _selectedById.containsKey(serviceId);

  bool select(AdditionalService service) {
    if (contains(service.id)) {
      return false;
    }

    _selectedById[service.id] = service;
    notifyListeners();
    return true;
  }

  bool unselect(String serviceId) {
    if (_selectedById.remove(serviceId) == null) {
      return false;
    }

    notifyListeners();
    return true;
  }

  bool toggle(AdditionalService service) {
    if (contains(service.id)) {
      unselect(service.id);
      return false;
    }

    select(service);
    return true;
  }
}
