import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/auth_service.dart';

enum AuthStatus { idle, loading, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  bool _isLoading = true; // true on startup while we wait for auth state

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _setStatus(AuthStatus.loading);
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred == null) {
        _setStatus(AuthStatus.idle);
        return false;
      }
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setStatus(AuthStatus.loading);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    _setStatus(AuthStatus.loading);
    try {
      await _authService.registerWithEmail(email: email, password: password);
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _errorMessage = null;
    _setStatus(AuthStatus.idle);
  }

  void _setStatus(AuthStatus s) {
    _status = s;
    notifyListeners();
  }
}