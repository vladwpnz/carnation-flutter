import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/features/user_auth/domain/auth_validators.dart';
import 'package:carnation/features/user_auth/domain/user_profile.dart';
import 'package:carnation/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:carnation/features/user_auth/presentation/pages/login_page.dart';
import 'package:carnation/main.dart';

void main() {
  group('AuthValidators', () {
    test('validates username length after trimming', () {
      expect(AuthValidators.username('  al  '), isNotNull);
      expect(AuthValidators.username('  alex  '), isNull);
      expect(AuthValidators.username('a' * 31), isNotNull);
    });

    test('validates email structure after trimming', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('not-an-email'), isNotNull);
      expect(AuthValidators.email(' user@example.com '), isNull);
    });

    test('validates password without trimming it', () {
      expect(AuthValidators.password(''), isNotNull);
      expect(AuthValidators.password('12345'), isNotNull);
      expect(AuthValidators.password(' 1234 '), isNull);
    });
  });

  group('FirebaseAuthService messages', () {
    test('maps known Firebase Auth error codes', () {
      final messagesByCode = <String, String>{
        'invalid-email': 'Enter a valid email address.',
        'invalid-credential': 'The email or password is incorrect.',
        'wrong-password': 'The password is incorrect.',
        'user-not-found': 'No account exists for this email.',
        'user-disabled': 'This account has been disabled.',
        'email-already-in-use': 'An account already exists for this email.',
        'weak-password': 'Choose a stronger password.',
        'operation-not-allowed': 'Email and password sign-in is not enabled.',
        'network-request-failed':
            'Network error. Check your connection and try again.',
        'too-many-requests': 'Too many attempts. Please try again later.',
      };

      for (final entry in messagesByCode.entries) {
        expect(FirebaseAuthService.messageForCode(entry.key), entry.value);
      }
    });

    test('uses a safe fallback for unknown codes', () {
      expect(
        FirebaseAuthService.messageForCode('unknown-code'),
        'Authentication failed. Please try again.',
      );
    });
  });

  group('UserProfile', () {
    test('parses profile data defensively', () {
      final profile = UserProfile.fromMap({
        'uid': ' user-1 ',
        'username': ' Alex ',
        'email': ' alex@example.com ',
      });

      expect(profile.uid, 'user-1');
      expect(profile.username, 'Alex');
      expect(profile.email, 'alex@example.com');
    });

    test('uses fallbacks for missing or invalid fields', () {
      final profile = UserProfile.fromMap(
        {
          'uid': 100,
          'username': '',
          'email': null,
        },
        fallbackUid: 'fallback-uid',
        fallbackUsername: 'Fallback User',
        fallbackEmail: 'fallback@example.com',
      );

      expect(profile.uid, 'fallback-uid');
      expect(profile.username, 'Fallback User');
      expect(profile.email, 'fallback@example.com');
    });
  });

  testWidgets('AuthGate shows LoginPage when signed out', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          authStateChanges: Stream<User?>.value(null),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
}
