import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/firebase_repository.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseRepository _repository;

  AuthProvider(this._repository) {
    // Подписка на изменения состояния аутентификации
    _repository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.register(email, password, name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _currentUser = await _repository.getCurrentUser();
    notifyListeners();
  }
}