import 'package:firebase_auth/firebase_auth.dart';

class AuthServiceException implements Exception {
  final String code;
  final String message;

  const AuthServiceException({
    required this.code,
    required this.message,
  });

  factory AuthServiceException.fromCode(String code) {
    return AuthServiceException(
      code: code,
      message: FirebaseAuthService.messageForCode(code),
    );
  }

  @override
  String toString() => message;
}

class FirebaseAuthService {
  final FirebaseAuth? _auth;

  const FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential);
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException.fromCode(error.code);
    }
  }

  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential);
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException.fromCode(error.code);
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = currentUser;

    if (user == null) {
      throw const AuthServiceException(
        code: 'no-current-user',
        message: 'No signed-in user is available.',
      );
    }

    try {
      await user.updateDisplayName(displayName);
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException.fromCode(error.code);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException.fromCode(error.code);
    }
  }

  static String messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'user-not-found':
        return 'No account exists for this email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'operation-not-allowed':
        return 'Email and password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  User _requireUser(UserCredential credential) {
    final user = credential.user;

    if (user == null) {
      throw const AuthServiceException(
        code: 'missing-user',
        message: 'Authentication completed without a user profile.',
      );
    }

    return user;
  }
}
