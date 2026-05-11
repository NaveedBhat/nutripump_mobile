import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_profile.dart';
import '../notification_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _google = GoogleSignIn();

  /// Stream of current user profile (null = signed out)
  Stream<UserProfile?> getProfileStream(User user) async* {
    // Ensure profile document is created if this is first login
    await _fetchOrCreateProfile(user);
    // Save / refresh the FCM token whenever auth state resolves a user
    NotificationService.instance.saveTokenForUser(user.uid);
    // Stream real-time updates from Firestore
    yield* _db.collection('users').doc(user.uid).snapshots().map((snap) {
      if (snap.exists) return UserProfile.fromFirestore(snap);
      return null;
    }).handleError((e) {
      // Swallow permission errors that occur during sign-out race conditions
    });
  }

  Future<UserProfile?> _fetchOrCreateProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return UserProfile.fromFirestore(snap);

    // First time — create profile
    final profile = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'role': 'user',
      'emailVerified': user.emailVerified,
      'totalOrders': 0,
      'totalSpent': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
    await ref.set(profile, SetOptions(merge: true));
    final created = await ref.get();
    return UserProfile.fromFirestore(created);
  }

  Future<User> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    try {
      await _db.collection('users').doc(result.user!.uid).set({
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Ignore if updating lastLoginAt fails (e.g. firestore rule or offline)
    }
    return result.user!;
  }

  Future<User> registerWithEmail(
      String email, String password, String displayName) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await result.user!.updateDisplayName(displayName);
    await result.user!.sendEmailVerification();
    return result.user!;
  }

  Future<User?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    await _fetchOrCreateProfile(result.user!);
    return result.user;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> sendEmailVerification() =>
      _auth.currentUser?.sendEmailVerification() ?? Future.value();

  Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> saveFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
    if (data.containsKey('displayName')) {
      await _auth.currentUser?.updateDisplayName(data['displayName'] as String);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'For your security, please sign out and sign back in before changing your password.',
        );
      }
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      // Delete Auth record FIRST. If this throws requires-recent-login,
      // the Firestore document is untouched — no orphaned data.
      await user.delete();
      // Only delete Firestore profile after Auth deletion succeeds.
      // Cloud Functions handle cascading deletes (orders, addresses, etc.)
      await _db.collection('users').doc(user.uid).delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'For your security, please sign out and sign back in before deleting your account.',
        );
      }
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;
}
