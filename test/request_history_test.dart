import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';
import 'package:carnation/features/requests/presentation/pages/my_requests_page.dart';
import 'package:carnation/features/requests/presentation/pages/request_details_page.dart';

import 'helpers/fake_vehicle_request_repository.dart';

void main() {
  testWidgets('My Requests shows the empty state', (tester) async {
    final repository = FakeVehicleRequestRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(_app(MyRequestsPage(
      requestRepository: repository,
    )));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('my-requests-empty')), findsOneWidget);
    expect(find.text('No requests yet'), findsOneWidget);
    expect(find.textContaining('Submitted vehicle requests'), findsOneWidget);
  });

  testWidgets('My Requests renders loaded cards and status labels', (
    tester,
  ) async {
    final repository = FakeVehicleRequestRepository(
      requests: [
        sampleVehicleRequest(
          id: 'submitted-request',
          status: VehicleRequestStatus.submitted,
        ),
        sampleVehicleRequest(
          id: 'offer-request',
          status: VehicleRequestStatus.offerPrepared,
        ),
      ],
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(_app(MyRequestsPage(
      requestRepository: repository,
    )));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('request-card-submitted-request')),
        findsOneWidget);
    expect(find.byKey(const Key('request-card-offer-request')), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('Offer prepared'), findsOneWidget);
    expect(find.text(r'$62,450'), findsNWidgets(2));
  });

  testWidgets('View details opens Request Details for the full ID', (
    tester,
  ) async {
    final request = sampleVehicleRequest(id: 'full-firestore-document-id');
    final repository = FakeVehicleRequestRepository(requests: [request]);
    addTearDown(repository.dispose);

    await tester.pumpWidget(_app(MyRequestsPage(
      requestRepository: repository,
    )));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('view-request-full-firestore-document-id')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RequestDetailsPage), findsOneWidget);
    expect(find.text('Request details'), findsOneWidget);
    expect(find.text('full-firestore-document-id'), findsOneWidget);
  });
}

Widget _app(Widget home) {
  return MaterialApp(theme: CarNationTheme.dark, home: home);
}
