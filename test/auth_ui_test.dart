import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/app/splash_screen/splash_screen.dart';
import 'package:carnation/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:carnation/features/user_auth/presentation/pages/login_page.dart';
import 'package:carnation/features/user_auth/presentation/pages/sign_up_page.dart';

void main() {
  testWidgets('Splash shows CarNation branding and loading state', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const SplashScreen()));

    expect(find.text('CarNation'), findsOneWidget);
    expect(
        find.text('Find the car that fits your next journey.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Login and Sign Up expose controls and navigate between pages', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const LoginPage()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign Up'), findsOneWidget);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpPage), findsOneWidget);
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Log In'), findsOneWidget);

    await tester.ensureVisible(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Password visibility toggle changes obscuring', (tester) async {
    await tester.pumpWidget(_testApp(const LoginPage()));

    EditableText passwordField() {
      return tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );
    }

    expect(passwordField().obscureText, isTrue);
    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(passwordField().obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('Login shows existing validation feedback', (tester) async {
    await tester.pumpWidget(_testApp(const LoginPage()));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Login disables submission while authentication is pending', (
    tester,
  ) async {
    final authService = _PendingSignInAuthService();
    await tester.pumpWidget(_testApp(LoginPage(authService: authService)));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Signing in...'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('Auth pages remain scrollable on small screens with larger text',
      (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(
      tester.platformDispatcher.clearTextScaleFactorTestValue,
    );

    await tester.pumpWidget(_testApp(const LoginPage()));
    await tester.ensureVisible(find.text('Sign Up'));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create account'));

    expect(find.byType(SignUpPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget home) {
  return MaterialApp(
    theme: CarNationTheme.dark,
    home: home,
  );
}

class _PendingSignInAuthService extends FirebaseAuthService {
  final Completer<User> _completer = Completer<User>();

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) {
    return _completer.future;
  }
}
