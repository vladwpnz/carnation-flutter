import 'package:motor_show/features/requests/domain/additional_service.dart';

const localAdditionalServices = <AdditionalService>[
  AdditionalService(
    id: 'pre-delivery-inspection',
    title: 'Full pre-delivery inspection and service',
    description: 'A comprehensive mechanical inspection and scheduled service.',
    price: 600,
  ),
  AdditionalService(
    id: 'detailing',
    title: 'Interior and exterior detailing',
    description: 'Professional preparation of the cabin and exterior finish.',
    price: 350,
  ),
  AdditionalService(
    id: 'extended-warranty',
    title: 'Extended warranty',
    description: 'Additional warranty coverage discussed with a representative.',
    price: 1500,
  ),
  AdditionalService(
    id: 'winter-wheel-package',
    title: 'Winter wheel package',
    description: 'A complete seasonal wheel and tire package for the vehicle.',
    price: 2000,
  ),
  AdditionalService(
    id: 'vehicle-delivery',
    title: 'Vehicle delivery',
    description: 'Arrange delivery details with a CarNation representative.',
    price: 250,
  ),
  AdditionalService(
    id: 'registration-assistance',
    title: 'Registration assistance',
    description: 'Guidance and document support for vehicle registration.',
    price: 200,
  ),
  AdditionalService(
    id: 'trade-in-consultation',
    title: 'Trade-in consultation',
    description: 'Discuss a potential trade-in with a CarNation representative.',
    price: 0,
  ),
  AdditionalService(
    id: 'test-drive',
    title: 'Book a test drive',
    description: 'Request a convenient time to experience the selected vehicle.',
    price: 0,
  ),
];
