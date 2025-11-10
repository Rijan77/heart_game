import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String _error = '';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null && _token != null;  

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      _token = await _storage.read(key: 'token');
      final userData = await _storage.read(key: 'user');

      if (_token != null && userData != null) {
        _user = User.fromJson(json.decode(userData));
        notifyListeners();
      }
    } catch (e) {
      await _storage.deleteAll();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.register(username, email, password);

      if (response.success && response.token != null && response.user != null) {
        _user = response.user;
        _token = response.token;

        await _storage.write(key: 'token', value: _token);
        await _storage.write(
          key: 'user',
          value: json.encode(response.user!.toJson()),
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);

      if (response.success && response.token != null && response.user != null) {
        _user = response.user;
        _token = response.token;

        await _storage.write(key: 'token', value: _token);
        await _storage.write(
          key: 'user',
          value: json.encode(response.user!.toJson()),
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = '';

    await _storage.deleteAll();
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
