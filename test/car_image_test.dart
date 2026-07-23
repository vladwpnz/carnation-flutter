import 'package:carnation/features/cars/presentation/widgets/car_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('brand fallback mapping uses the four legacy assets', () {
    expect(carImageFallbackForBrand('BMW'), 'assets/car1.jpg');
    expect(carImageFallbackForBrand('Volkswagen'), 'assets/car2.jpg');
    expect(carImageFallbackForBrand('Ford'), 'assets/car3.jpg');
    expect(carImageFallbackForBrand('Audi'), 'assets/car4.jpg');
    expect(carImageFallbackForBrand('Unknown'), isNull);
  });

  test('infers a snapshot brand from its final path or display name', () {
    expect(
      inferCarImageBrand(
        imagePath: 'assets/cars/audi/audi-a3-2021.webp',
      ),
      'Audi',
    );
    expect(
      inferCarImageBrand(imagePath: '', displayName: 'Ford Focus 2015'),
      'Ford',
    );
  });

  testWidgets('renders primary asset normally and preserves requested fit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 320,
          height: 200,
          child: CarImage(
            imagePath: 'assets/cars/bmw/bmw-m4-2014.webp',
            brand: 'BMW',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final carImage = find.byType(CarImage);
    final primaryImage = tester.widget<Image>(
      find.descendant(of: carImage, matching: find.byType(Image)),
    );
    expect((primaryImage.image as AssetImage).assetName,
        'assets/cars/bmw/bmw-m4-2014.webp');
    expect(primaryImage.fit, BoxFit.contain);
    expect(
      find.descendant(of: carImage, matching: find.byType(Transform)),
      findsNothing,
    );
    expect(
      find.descendant(of: carImage, matching: find.byType(ClipRect)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing final image renders its legacy fallback without errors',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 320,
          height: 200,
          child: CarImage(
            imagePath: 'assets/cars/bmw/missing-car-image.webp',
            brand: 'BMW',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map(
          (image) => image.image,
        )
        .whereType<AssetImage>()
        .map((image) => image.assetName);
    expect(assetNames, contains('assets/car1.jpg'));
  });

  testWidgets('uses a neutral placeholder when no fallback is available', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 320,
          height: 200,
          child: CarImage(
            imagePath: 'assets/cars/unknown/missing-image.webp',
            brand: 'Unknown',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final carImage = find.byType(CarImage);
    expect(
      find.descendant(
        of: carImage,
        matching: find.byIcon(Icons.directions_car_filled_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: carImage, matching: find.byType(Transform)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
