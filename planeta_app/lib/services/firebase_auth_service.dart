import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_entity.dart';
import 'auth_service.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(credential.user);
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
