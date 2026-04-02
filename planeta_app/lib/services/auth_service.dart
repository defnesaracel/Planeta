/*
class AuthService {
  //mock method
  Future<bool> login(String email, String password) async {
    print("Login trial: $email");
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  //authentication method
  Future<bool> register(String email, String password, String username) async {
    print("authentication trial: $username");
    return true;
  }
}*/

import 'package:planeta_app/model/user_entity.dart';

abstract class IAuthService {
  Future<UserEntity?> signIn(String email, String password);
  Future<UserEntity?> signUp(String email, String password, String username);
  Future<void> signOut();
  Stream<UserEntity?> get onAuthStateChanged;
}
