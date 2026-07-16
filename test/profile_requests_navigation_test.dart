import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/requests/presentation/pages/my_requests_page.dart';
import 'package:carnation/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:carnation/features/user_auth/presentation/pages/profile_page.dart';

import 'helpers/fake_vehicle_request_repository.dart';

void main() {
  testWidgets('Profile shows My requests and opens request history', (
    tester,
  ) async {
    final repository = FakeVehicleRequestRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: CarNationTheme.dark,
        home: ProfilePage(
          authService: const _SignedOutTestAuthService(),
          requestRepository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-my-requests')), findsOneWidget);
    expect(find.text('My requests'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-my-requests')));
    await tester.pumpAndSettle();

    expect(find.byType(MyRequestsPage), findsOneWidget);
    expect(find.byKey(const Key('my-requests-empty')), findsOneWidget);
  });
}

class _SignedOutTestAuthService extends FirebaseAuthService {
  const _SignedOutTestAuthService();

  @override
  User? get currentUser => null;
}
