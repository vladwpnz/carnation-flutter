import 'package:carnation/features/cars/data/catalog/audi_cars.dart';
import 'package:carnation/features/cars/data/catalog/bmw_cars.dart';
import 'package:carnation/features/cars/data/catalog/ford_cars.dart';
import 'package:carnation/features/cars/data/catalog/volkswagen_cars.dart';
import 'package:carnation/features/cars/domain/car.dart';

const localCarCatalog = <Car>[
  ...bmwCars,
  ...volkswagenCars,
  ...fordCars,
  ...audiCars,
];
