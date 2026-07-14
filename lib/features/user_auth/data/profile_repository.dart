import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motor_show/features/user_auth/domain/user_profile.dart';

class ProfileRepository {
  final FirebaseFirestore? _firestore;

  const ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Future<void> saveUserProfile({
    required String uid,
    required String username,
    required String email,
  }) {
    return _db.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserProfile?> loadUserProfile(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return UserProfile.fromMap(
      snapshot.data(),
      fallbackUid: uid,
    );
  }
}
