import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../core/network/socket_client.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocketClient _socketClient = SocketClient();

  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    File? profilePicture,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.register(
      username: username,
      email: email,
      password: password,
      profilePicture: profilePicture,
    );

    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
      notifyListeners();
      _setLoading(false);
      return true;
    } else {
      _setError(result['message']);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
      await _socketClient.connect();
      notifyListeners();
      _setLoading(false);
      return true;
    } else {
      _setError(result['message']);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    await _authService.logout();
    _socketClient.disconnect();
    
    _user = null;
    _isLoggedIn = false;
    _clearError();
    _setLoading(false);
    notifyListeners();
  }
  Future<void> checkAuthStatus() async {
    print('[AuthProvider] Checking auth status...');
    
    final token = await _authService.getToken();
    if (token != null) {
      print('[AuthProvider] Token found, validating...');
      
      try {
        // Validate token dan ambil user data dari server
        final userProfile = await _authService.getUserProfile();
        if (userProfile['success']) {
          print('[AuthProvider] Token valid, setting user data');
          _user = userProfile['user'];
          _isLoggedIn = true;
          await _socketClient.connect();
          notifyListeners();
        } else {
          print('[AuthProvider] Token invalid, clearing...');
          // Token invalid, clear it
          await _authService.logout();
          _user = null;
          _isLoggedIn = false;
          notifyListeners();
        }
      } catch (e) {
        print('[AuthProvider] Error validating token: $e');
        // Token bermasalah, clear it
        await _authService.logout();
        _user = null;
        _isLoggedIn = false;
        notifyListeners();
      }
    } else {
      print('[AuthProvider] No token found');
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
