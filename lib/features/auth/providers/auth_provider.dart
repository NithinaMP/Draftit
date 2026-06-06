// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../data/auth_service.dart';
//
// enum AuthStatus { idle, loading, error }
//
// class AuthProvider extends ChangeNotifier {
//   final AuthService _authService = AuthService();
//
//   User? _user;
//   AuthStatus _status = AuthStatus.idle;
//   String? _errorMessage;
//   bool _isLoading = true;
//
//   User? get user => _user;
//   AuthStatus get status => _status;
//   String? get errorMessage => _errorMessage;
//   bool get isLoading => _isLoading;
//
//   /// Display name: prefer Firebase displayName, fallback to email prefix
//   String get displayName {
//     if (_user == null) return '';
//     if (_user!.displayName != null && _user!.displayName!.isNotEmpty) {
//       return _user!.displayName!;
//     }
//     final email = _user!.email ?? '';
//     return email.contains('@') ? email.split('@').first : email;
//   }
//
//   String get initials {
//     final name = displayName;
//     if (name.isEmpty) return 'U';
//     final parts = name.trim().split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return name[0].toUpperCase();
//   }
//
//   AuthProvider() {
//     _authService.authStateChanges.listen((user) {
//       _user = user;
//       _isLoading = false;
//       notifyListeners();
//     });
//   }
//
//   Future<bool> signInWithGoogle() async {
//     _setStatus(AuthStatus.loading);
//     _errorMessage = null;
//     try {
//       final cred = await _authService.signInWithGoogle();
//       if (cred == null) {
//         _setStatus(AuthStatus.idle);
//         return false;
//       }
//       _user = cred.user;
//       _setStatus(AuthStatus.idle);
//       return true;
//     } on FirebaseAuthException catch (e) {
//       _errorMessage = _authService.getFriendlyError(e.code);
//       _setStatus(AuthStatus.error);
//       return false;
//     } catch (e) {
//       _errorMessage = 'Google Sign-In failed: ${e.toString()}';
//       _setStatus(AuthStatus.error);
//       return false;
//     }
//   }
//
//   Future<bool> signInWithEmail(String email, String password) async {
//     _setStatus(AuthStatus.loading);
//     _errorMessage = null;
//     try {
//       final cred = await _authService.signInWithEmail(
//           email: email, password: password);
//       _user = cred.user;
//       _setStatus(AuthStatus.idle);
//       return true;
//     } on FirebaseAuthException catch (e) {
//       _errorMessage = _authService.getFriendlyError(e.code);
//       _setStatus(AuthStatus.error);
//       return false;
//     }
//   }
//
//   Future<bool> registerWithEmail({
//     required String email,
//     required String password,
//     required String displayName,
//   }) async {
//     _setStatus(AuthStatus.loading);
//     _errorMessage = null;
//     try {
//       final cred = await _authService.registerWithEmail(
//         email: email,
//         password: password,
//         displayName: displayName,
//       );
//       _user = cred.user;
//       _setStatus(AuthStatus.idle);
//       return true;
//     } on FirebaseAuthException catch (e) {
//       _errorMessage = _authService.getFriendlyError(e.code);
//       _setStatus(AuthStatus.error);
//       return false;
//     }
//   }
//
//   Future<void> signOut() async {
//     await _authService.signOut();
//     _user = null;
//     notifyListeners();
//   }
//
//   void clearError() {
//     _errorMessage = null;
//     _setStatus(AuthStatus.idle);
//   }
//
//   void _setStatus(AuthStatus s) {
//     _status = s;
//     notifyListeners();
//   }
// }



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
  bool get isGoogleUser => _authService.isGoogleUser;

  // FIX: Always read displayName from FirebaseAuth.instance.currentUser
  // so that after updateDisplayName + reload(), it's immediately fresh
  String get displayName {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return '';
    if (u.displayName != null && u.displayName!.isNotEmpty) {
      return u.displayName!;
    }
    final email = u.email ?? '';
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
      if (cred == null) { _setStatus(AuthStatus.idle); return false; }
      _user = cred.user;
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: $e';
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
          email: email, password: password, displayName: displayName);
      _user = cred.user;
      // FIX: reload from server so displayName is fresh
      await FirebaseAuth.instance.currentUser?.reload();
      _user = FirebaseAuth.instance.currentUser;
      _setStatus(AuthStatus.idle);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;
    try {
      await _authService.changePassword(
          currentPassword: currentPassword, newPassword: newPassword);
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> deleteAccount({String? password}) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;
    try {
      if (isGoogleUser) {
        await _authService.deleteGoogleAccount();
      } else {
        await _authService.deleteAccount(password: password ?? '');
      }
      _user = null;
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setStatus(AuthStatus.loading);
    _errorMessage = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      _setStatus(AuthStatus.idle);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getFriendlyError(e.code);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<void> updateDisplayName(String name) async {
    await _authService.updateDisplayName(name);
    await FirebaseAuth.instance.currentUser?.reload();
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _errorMessage = null;
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