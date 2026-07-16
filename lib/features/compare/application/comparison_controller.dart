import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:motor_show/features/cars/domain/car.dart';

enum ComparisonAddResult {
  added,
  alreadySelected,
  limitReached,
}

enum ComparisonToggleResult {
  added,
  removed,
  limitReached,
}

class ComparisonController extends ChangeNotifier {
  static const maxVehicles = 3;

  final Map<String, Car> _carsById = <String, Car>{};

  UnmodifiableListView<Car> get cars {
    return UnmodifiableListView<Car>(_carsById.values);
  }

  int get count => _carsById.length;
  bool get isEmpty => _carsById.isEmpty;
  bool get isFull => count >= maxVehicles;

  bool contains(String carId) => _carsById.containsKey(carId);

  ComparisonAddResult add(Car car) {
    if (contains(car.id)) {
      return ComparisonAddResult.alreadySelected;
    }
    if (isFull) {
      return ComparisonAddResult.limitReached;
    }

    _carsById[car.id] = car;
    notifyListeners();
    return ComparisonAddResult.added;
  }

  bool remove(String carId) {
    if (_carsById.remove(carId) == null) {
      return false;
    }

    notifyListeners();
    return true;
  }

  ComparisonToggleResult toggle(Car car) {
    if (contains(car.id)) {
      remove(car.id);
      return ComparisonToggleResult.removed;
    }

    final result = add(car);
    return result == ComparisonAddResult.limitReached
        ? ComparisonToggleResult.limitReached
        : ComparisonToggleResult.added;
  }

  void clear() {
    if (_carsById.isEmpty) {
      return;
    }

    _carsById.clear();
    notifyListeners();
  }
}
