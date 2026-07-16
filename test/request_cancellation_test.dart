import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/requests/data/vehicle_request_repository.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';
import 'package:carnation/features/requests/presentation/pages/request_details_page.dart';

import 'helpers/fake_vehicle_request_repository.dart';

void main() {
  testWidgets('submitted request can be cancelled and remains in history', (
    tester,
  ) async {
    final request = sampleVehicleRequest();
    final repository = FakeVehicleRequestRepository(requests: [request]);
    addTearDown(repository.dispose);
    await tester.pumpWidget(_detailsApp(repository, request.id));
    await tester.pumpAndSettle();

    await _confirmCancellation(tester);
    await tester.pumpAndSettle();

    expect(repository.cancellationCallCount, 1);
    expect(find.text('Request cancelled.'), findsOneWidget);
    expect(find.byKey(const Key('request-status-cancelled')), findsOneWidget);
    expect(find.byKey(const Key('cancel-request')), findsNothing);
  });

  testWidgets('non-submitted request cannot be cancelled', (tester) async {
    final request = sampleVehicleRequest(
      status: VehicleRequestStatus.underReview,
    );
    final repository = FakeVehicleRequestRepository(requests: [request]);
    addTearDown(repository.dispose);
    await tester.pumpWidget(_detailsApp(repository, request.id));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cancel-request')), findsNothing);
    await expectLater(
      repository.cancelSubmittedRequest(request.id),
      throwsA(
        isA<VehicleRequestRepositoryException>().having(
          (error) => error.code,
          'code',
          'request-not-cancellable',
        ),
      ),
    );
  });

  testWidgets('repeated cancellation is prevented while pending', (
    tester,
  ) async {
    final request = sampleVehicleRequest();
    final repository = FakeVehicleRequestRepository(requests: [request]);
    final completion = Completer<void>();
    repository.cancellationCompleter = completion;
    addTearDown(repository.dispose);
    await tester.pumpWidget(_detailsApp(repository, request.id));
    await tester.pumpAndSettle();

    await _confirmCancellation(tester);
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('cancel-request')),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(repository.cancellationCallCount, 1);
    expect(find.text('Cancelling...'), findsOneWidget);

    completion.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('failed cancellation shows a recoverable error', (
    tester,
  ) async {
    final request = sampleVehicleRequest();
    final repository = FakeVehicleRequestRepository(requests: [request])
      ..cancellationError = const VehicleRequestRepositoryException(
        code: 'unavailable',
        message: 'The request service is unavailable. Please try again.',
      );
    addTearDown(repository.dispose);
    await tester.pumpWidget(_detailsApp(repository, request.id));
    await tester.pumpAndSettle();

    await _confirmCancellation(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cancellation-error')), findsOneWidget);
    expect(find.textContaining('Please try again'), findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Cancel request'),
    );
    expect(button.onPressed, isNotNull);
  });
}

Widget _detailsApp(
  FakeVehicleRequestRepository repository,
  String requestId,
) {
  return MaterialApp(
    theme: CarNationTheme.dark,
    home: RequestDetailsPage(
      requestId: requestId,
      requestRepository: repository,
    ),
  );
}

Future<void> _confirmCancellation(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('cancel-request')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('cancel-request')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('confirm-cancel-request')));
  await tester.pump();
}
