import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';
import 'package:motor_show/features/cars/presentation/pages/car_details_page.dart';
import 'package:motor_show/features/compare/application/comparison_controller.dart';
import 'package:motor_show/features/compare/presentation/pages/compare_page.dart';
import 'package:motor_show/features/requests/presentation/pages/request_builder_page.dart';
import 'package:motor_show/features/saved/application/saved_cars_controller.dart';
import 'package:motor_show/features/saved/presentation/pages/saved_cars_page.dart';
import 'package:motor_show/features/user_auth/presentation/pages/home_page.dart';

void main() {
  testWidgets('Home View details opens Vehicle Details', (tester) async {
    final controllers = _MarketplaceControllers();
    addTearDown(controllers.dispose);
    await tester.pumpWidget(_testApp(controllers.home));

    final detailsButton = find.byKey(
      const Key('view-details-bmw-m4-2014'),
    );
    await tester.ensureVisible(detailsButton);
    await tester.pumpAndSettle();
    await tester.tap(detailsButton);
    await tester.pumpAndSettle();

    expect(find.byType(CarDetailsPage), findsOneWidget);
    expect(find.text('Vehicle details'), findsOneWidget);
    expect(find.text('Request an offer'), findsOneWidget);
  });

  testWidgets('Request an offer opens Request Builder for one vehicle', (
    tester,
  ) async {
    final controllers = _MarketplaceControllers();
    addTearDown(controllers.dispose);
    await tester.pumpWidget(_testApp(controllers.home));

    final detailsButton = find.byKey(
      const Key('view-details-bmw-m4-2014'),
    );
    await tester.ensureVisible(detailsButton);
    await tester.pumpAndSettle();
    await tester.tap(detailsButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('request-offer')));
    await tester.pumpAndSettle();

    expect(find.byType(RequestBuilderPage), findsOneWidget);
    expect(find.text('Build your request'), findsOneWidget);
    expect(find.text('BMW M4 2014'), findsOneWidget);
  });

  testWidgets('Saved header action opens Saved Cars', (tester) async {
    final controllers = _MarketplaceControllers();
    addTearDown(controllers.dispose);
    await tester.pumpWidget(_testApp(controllers.home));

    await tester.tap(find.byKey(const Key('open-saved-cars')));
    await tester.pumpAndSettle();

    expect(find.byType(SavedCarsPage), findsOneWidget);
    expect(find.text('No saved cars yet'), findsOneWidget);
  });

  testWidgets('Compare menu action opens Compare Page', (tester) async {
    final controllers = _MarketplaceControllers();
    addTearDown(controllers.dispose);
    await tester.pumpWidget(_testApp(controllers.home));

    await tester.tap(find.byKey(const Key('home-more-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compare vehicles'));
    await tester.pumpAndSettle();

    expect(find.byType(ComparePage), findsOneWidget);
    expect(find.text('No vehicles to compare'), findsOneWidget);
  });

  testWidgets('Saving from a catalogue card updates shared state and badge', (
    tester,
  ) async {
    final controllers = _MarketplaceControllers();
    addTearDown(controllers.dispose);
    await tester.pumpWidget(_testApp(controllers.home));

    await tester.tap(find.byKey(const Key('save-car-bmw-m4-2014')));
    await tester.pump();

    expect(controllers.saved.count, 1);
    expect(find.text('1'), findsOneWidget);
  });
}

Widget _testApp(Widget home) {
  return MaterialApp(theme: CarNationTheme.dark, home: home);
}

class _MarketplaceControllers {
  final saved = SavedCarsController();
  final comparison = ComparisonController();

  HomePage get home => HomePage(
        savedCarsController: saved,
        comparisonController: comparison,
      );

  void dispose() {
    saved.dispose();
    comparison.dispose();
  }
}
