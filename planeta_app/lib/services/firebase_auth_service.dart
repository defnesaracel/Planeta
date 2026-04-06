import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_entity.dart';
import 'auth_service.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserEntity? _mapFirebaseUser(User? user) {
    return user != null ? UserEntity(uid: user.uid, email: user.email!) : null;
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(credential.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signUp(
    String email,
    String password,
    String username,
  ) async {
    try {
      final passwordRegExp = RegExp(r'^(?=.*[0-9]).{4,8}$');
      if (!passwordRegExp.hasMatch(password)) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message:
              'Password must be 4-8 characters long and include at least one number.',
        );
      }

      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message: 'This username is already taken.',
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await credential.user!.updateDisplayName(username);
      }

      return _mapFirebaseUser(credential.user);
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<UserEntity?> get onAuthStateChanged =>
      _auth.authStateChanges().map(_mapFirebaseUser);
}
