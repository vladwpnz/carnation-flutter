import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';
import 'package:motor_show/features/app/splash_screen/splash_screen.dart';
import 'package:motor_show/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:motor_show/features/user_auth/presentation/pages/home_page.dart';
import 'package:motor_show/features/user_auth/presentation/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDK3OkuTinZhA8RFDC-rslJcbRy1qx9KSs",
          appId: "1:944742015061:web:957068bce593de379b34dc",
          messagingSenderId: "944742015061",
          projectId: "motor-show-firebase"),
    );
    return;
  }

  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  final FirebaseAuthService? authService;
  final Stream<User?>? authStateChanges;
  final User? initialUser;

  const MyApp({
    super.key,
    this.authService,
    this.authStateChanges,
    this.initialUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarNation',
      theme: CarNationTheme.dark,
      home: AuthGate(
        authService: authService,
        authStateChanges: authStateChanges,
        initialUser: initialUser,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final FirebaseAuthService? authService;
  final Stream<User?>? authStateChanges;
  final User? initialUser;

  const AuthGate({
    super.key,
    this.authService,
    this.authStateChanges,
    this.initialUser,
  });

  @override
  Widget build(BuildContext context) {
    final service = authStateChanges == null
        ? authService ?? const FirebaseAuthService()
        : authService;
    final stream = authStateChanges ?? service!.authStateChanges;
    final initialData = authStateChanges == null
        ? initialUser ?? service!.currentUser
        : initialUser;

    return StreamBuilder<User?>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SplashScreen();
        }

        if (snapshot.data != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
