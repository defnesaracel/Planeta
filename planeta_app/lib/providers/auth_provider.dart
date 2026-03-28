import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  // mock
  bool _isLoading = false;
  bool get isLoading => _isLoading;
}
