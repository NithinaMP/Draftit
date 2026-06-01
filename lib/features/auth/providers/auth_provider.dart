import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/auth_service.dart';

enum AuthStatus { idle, loading, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  bool _isLoading = true;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Display name: prefer Firebase displayName, fallback to email prefix
  String get displayName {
    if (_user == null) return '';
    if (_user!.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    final email = _user!.email ?? '';
    return email.contains('@') ? email.split('@').first : email;
  }

  String get initials {
    final name = displayName;
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred == null) {
        _setStatus(AuthStatus.idle);
        return false;
      }
      _user = cred.user;
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: ${e.toString()}';
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;
    try {
      final cred = await _authService.signInWithEmail(
          email: email, password: password);
      _user = cred.user;
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;
    try {
      final cred = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _user = cred.user;
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
    _user = null;
    notifyListeners();
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