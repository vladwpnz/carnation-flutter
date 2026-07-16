import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:motor_show/features/cars/domain/car.dart';

class SavedCarsController extends ChangeNotifier {
  final Map<String, Car> _carsById = <String, Car>{};

  UnmodifiableListView<Car> get cars {
    return UnmodifiableListView<Car>(_carsById.values);
  }

  int get count => _carsById.length;
  bool get isEmpty => _carsById.isEmpty;

  bool contains(String carId) => _carsById.containsKey(carId);

  bool save(Car car) {
    if (contains(car.id)) {
      return false;
    }

    _carsById[car.id] = car;
    notifyListeners();
    return true;
  }

  bool remove(String carId) {
    if (_carsById.remove(carId) == null) {
      return false;
    }

    notifyListeners();
    return true;
  }

  bool toggle(Car car) {
    if (contains(car.id)) {
      remove(car.id);
      return false;
    }

    save(car);
    return true;
  }

  void clear() {
    if (_carsById.isEmpty) {
      return;
    }

    _carsById.clear();
    notifyListeners();
  }
}
