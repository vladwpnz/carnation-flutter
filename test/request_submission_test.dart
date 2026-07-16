import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/requests/data/vehicle_request_repository.dart';
import 'package:carnation/features/requests/presentation/pages/request_builder_page.dart';
import 'package:carnation/features/requests/presentation/pages/request_confirmation_page.dart';

import 'helpers/fake_vehicle_request_repository.dart';

void main() {
  testWidgets('successful submission returns ID before opening success', (
    tester,
  ) async {
    final repository = FakeVehicleRequestRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(_builderApp(repository));

    await _submitAndConfirm(tester);
    await tester.pumpAndSettle();

    expect(repository.createCallCount, 1);
    expect(find.byType(RequestConfirmationPage), findsOneWidget);
    expect(find.text('CN-ABC12345'), findsOneWidget);
  });

  testWidgets('success navigation waits for repository completion', (
    tester,
  ) async {
    final repository = FakeVehicleRequestRepository();
    final completion = Completer<String>();
    repository.createCompleter = completion;
    addTearDown(repository.dispose);
    await tester.pumpWidget(_builderApp(repository));

    await _submitAndConfirm(tester);
    await tester.pump();

    expect(find.byType(RequestConfirmationPage), findsNothing);
    expect(find.byKey(const Key('submit-request-loading')), findsOneWidget);

    completion.complete('complete99document');
    await tester.pumpAndSettle();

    expect(find.byType(RequestConfirmationPage), findsOneWidget);
    expect(find.text('CN-COMPLETE'), findsOneWidget);
  });

  testWidgets('repository failure does not open success', (tester) async {
    final repository = FakeVehicleRequestRepository()
      ..createError = const VehicleRequestRepositoryException(
        code: 'unavailable',
        message: 'The request service is temporarily unavailable. Try again.',
      );
    addTearDown(repository.dispose);
    await tester.pumpWidget(_builderApp(repository));

    await _submitAndConfirm(tester);
    await tester.pumpAndSettle();

    expect(find.byType(RequestConfirmationPage), findsNothing);
    expect(find.byKey(const Key('request-submission-error')), findsOneWidget);
    expect(find.textContaining('temporarily unavailable'), findsOneWidget);
  });

  testWidgets('rapid duplicate submission is prevented', (tester) async {
    final repository = FakeVehicleRequestRepository();
    final completion = Completer<String>();
    repository.createCompleter = completion;
    addTearDown(repository.dispose);
    await tester.pumpWidget(_builderApp(repository));

    await _submitAndConfirm(tester);
    await tester.pump();
    await tester.tap(find.byKey(const Key('submit-request')));
    await tester.pump();

    expect(repository.createCallCount, 1);

    completion.complete('one-request-only');
    await tester.pumpAndSettle();
  });

  testWidgets('loading resets after submission failure', (tester) async {
    final repository = FakeVehicleRequestRepository()
      ..createError = StateError('raw failure must not be exposed');
    addTearDown(repository.dispose);
    await tester.pumpWidget(_builderApp(repository));

    await _submitAndConfirm(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('submit-request-loading')), findsNothing);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Submit request'),
    );
    expect(button.onPressed, isNotNull);
    expect(find.textContaining('raw failure'), findsNothing);
    expect(
      find.text('The request could not be submitted. Please try again.'),
      findsOneWidget,
    );
  });
}

Widget _builderApp(FakeVehicleRequestRepository repository) {
  return MaterialApp(
    theme: CarNationTheme.dark,
    home: RequestBuilderPage(
      car: sampleCar,
      requestRepository: repository,
    ),
  );
}

Future<void> _submitAndConfirm(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('submit-request')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('submit-request')));
  await tester.pumpAndSettle();
  final dialogSubmit = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text('Submit request'),
  );
  await tester.tap(dialogSubmit);
  await tester.pump();
}
