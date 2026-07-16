import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/requests/domain/vehicle_request.dart';
import 'package:carnation/features/requests/presentation/widgets/request_status_timeline.dart';

void main() {
  testWidgets('submitted timeline has one current stage and later upcoming', (
    tester,
  ) async {
    await _pumpTimeline(tester, VehicleRequestStatus.submitted);

    expect(
      find.byKey(const Key('timeline-submitted-current')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('timeline-underReview-upcoming')),
      findsOneWidget,
    );
  });

  testWidgets('under-review timeline completes only submitted', (
    tester,
  ) async {
    await _pumpTimeline(tester, VehicleRequestStatus.underReview);

    expect(
      find.byKey(const Key('timeline-submitted-completed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('timeline-underReview-current')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('timeline-customerContacted-upcoming')),
      findsOneWidget,
    );
  });

  testWidgets('completed timeline marks earlier stages complete', (
    tester,
  ) async {
    await _pumpTimeline(tester, VehicleRequestStatus.completed);

    expect(
      find.byKey(const Key('timeline-offerPrepared-completed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('timeline-completed-current')),
      findsOneWidget,
    );
  });

  testWidgets('cancelled timeline never completes future stages', (
    tester,
  ) async {
    await _pumpTimeline(tester, VehicleRequestStatus.cancelled);

    expect(
      find.byKey(const Key('timeline-cancelled-current')),
      findsOneWidget,
    );
    expect(
        find.text('The request will no longer be processed.'), findsOneWidget);
    expect(
      find.byKey(const Key('timeline-underReview-upcoming')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('timeline-underReview-completed')),
      findsNothing,
    );
  });
}

Future<void> _pumpTimeline(
  WidgetTester tester,
  VehicleRequestStatus status,
) {
  return tester.pumpWidget(
    MaterialApp(
      theme: CarNationTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          child: RequestStatusTimeline(status: status),
        ),
      ),
    ),
  );
}
