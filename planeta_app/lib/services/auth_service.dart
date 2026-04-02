import 'package:planeta_app/model/user_entity.dart';

abstract class IAuthService {
  Future<UserEntity?> signIn(String email, String password);
  Future<UserEntity?> signUp(String email, String password, String username);
  Future<void> signOut();
  Stream<UserEntity?> get onAuthStateChanged;
}
