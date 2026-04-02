import 'package:flutter/foundation.dart';
import 'package:planeta_app/model/user_entity.dart';
import 'package:planeta_app/services/auth_service.dart';
import 'package:planeta_app/services/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  // Dikkat: Burada FirebaseAuthService değil, IAuthService kullanıyoruz!
  // (Dependency Inversion prensibi)
  final IAuthService _authService = FirebaseAuthService();

  UserEntity? _user;
  bool _isLoading = false;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signIn(email, password);
    } catch (e) {
      _user = null;
      rethrow; // Hatayı UI katmanına fırlat ki kullanıcıya mesaj gösterebilelim
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signUp(email, password, username);
    } catch (e) {
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null; // Yerel kullanıcı verisini temizliyoruz
    } catch (e) {
      print("Sign Out Hatası: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
