// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:google_sign_in/google_sign_in.dart';
// //
// // class AuthService {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final GoogleSignIn _googleSignIn = GoogleSignIn();
// //
// //   Stream<User?> get authStateChanges => _auth.authStateChanges();
// //   User? get currentUser => _auth.currentUser;
// //
// //   /// Sign in with Google
// //   /// Requires SHA-1 fingerprint added in Firebase Console
// //   Future<UserCredential?> signInWithGoogle() async {
// //     // Sign out first to force account picker to show
// //     await _googleSignIn.signOut();
// //
// //     final googleUser = await _googleSignIn.signIn();
// //     if (googleUser == null) return null; // user cancelled
// //
// //     final googleAuth = await googleUser.authentication;
// //
// //     if (googleAuth.accessToken == null && googleAuth.idToken == null) {
// //       throw FirebaseAuthException(
// //         code: 'google-sign-in-failed',
// //         message:
// //         'Google authentication tokens are null. Make sure SHA-1 fingerprint is added in Firebase Console.',
// //       );
// //     }
// //
// //     final credential = GoogleAuthProvider.credential(
// //       accessToken: googleAuth.accessToken,
// //       idToken: googleAuth.idToken,
// //     );
// //
// //     return _auth.signInWithCredential(credential);
// //   }
// //
// //   /// Register with email + password + display name
// //   Future<UserCredential> registerWithEmail({
// //     required String email,
// //     required String password,
// //     required String displayName,
// //   }) async {
// //     final cred = await _auth.createUserWithEmailAndPassword(
// //       email: email,
// //       password: password,
// //     );
// //     // Save display name to Firebase Auth profile immediately
// //     await cred.user?.updateDisplayName(displayName.trim());
// //     await cred.user?.reload();
// //     return cred;
// //   }
// //
// //   /// Sign in with email + password
// //   Future<UserCredential> signInWithEmail({
// //     required String email,
// //     required String password,
// //   }) async {
// //     return _auth.signInWithEmailAndPassword(email: email, password: password);
// //   }
// //
// //   /// Sign out from both Google and Firebase
// //   Future<void> signOut() async {
// //     await _googleSignIn.signOut();
// //     await _auth.signOut();
// //   }
// //
// //   /// Update display name
// //   Future<void> updateDisplayName(String name) async {
// //     await _auth.currentUser?.updateDisplayName(name);
// //     await _auth.currentUser?.reload();
// //   }
// //
// //   String getFriendlyError(String code) {
// //     switch (code) {
// //       case 'user-not-found':
// //         return 'No account found with this email.';
// //       case 'wrong-password':
// //       case 'invalid-credential':
// //         return 'Incorrect email or password.';
// //       case 'email-already-in-use':
// //         return 'This email is already registered. Try signing in instead.';
// //       case 'invalid-email':
// //         return 'Please enter a valid email address.';
// //       case 'weak-password':
// //         return 'Password must be at least 6 characters.';
// //       case 'too-many-requests':
// //         return 'Too many attempts. Please wait a moment and try again.';
// //       case 'network-request-failed':
// //         return 'Network error. Check your internet connection.';
// //       case 'google-sign-in-failed':
// //         return 'Google Sign-In failed. Make sure your SHA-1 fingerprint is added in Firebase Console.\n\nRun: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android';
// //       default:
// //         return 'Something went wrong ($code). Please try again.';
// //     }
// //   }
// // }
//
//
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//   User? get currentUser => _auth.currentUser;
//
//   Future<UserCredential?> signInWithGoogle() async {
//     await _googleSignIn.signOut();
//     final googleUser = await _googleSignIn.signIn();
//     if (googleUser == null) return null;
//     final googleAuth = await googleUser.authentication;
//     if (googleAuth.accessToken == null && googleAuth.idToken == null) {
//       throw FirebaseAuthException(
//         code: 'google-sign-in-failed',
//         message: 'Google authentication failed. Add SHA-1 in Firebase Console.',
//       );
//     }
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//     return _auth.signInWithCredential(credential);
//   }
//
//   Future<UserCredential> registerWithEmail({
//     required String email,
//     required String password,
//     required String displayName,
//   }) async {
//     final cred = await _auth.createUserWithEmailAndPassword(
//         email: email, password: password);
//     await cred.user?.updateDisplayName(displayName.trim());
//     // reload so currentUser.displayName is immediately available
//     await cred.user?.reload();
//     return cred;
//   }
//
//   Future<UserCredential> signInWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     return _auth.signInWithEmailAndPassword(email: email, password: password);
//   }
//
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
//
//   Future<void> updateDisplayName(String name) async {
//     await _auth.currentUser?.updateDisplayName(name.trim());
//     await _auth.currentUser?.reload();
//   }
//
//   /// Change password — requires recent login
//   Future<void> changePassword({
//     required String currentPassword,
//     required String newPassword,
//   }) async {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('Not signed in');
//     if (user.email == null) throw Exception('No email on account');
//
//     // Re-authenticate first
//     final cred = EmailAuthProvider.credential(
//         email: user.email!, password: currentPassword);
//     await user.reauthenticateWithCredential(cred);
//     await user.updatePassword(newPassword);
//   }
//
//   /// Delete account — requires re-authentication
//   Future<void> deleteAccount({required String password}) async {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('Not signed in');
//
//     if (user.email != null) {
//       final cred = EmailAuthProvider.credential(
//           email: user.email!, password: password);
//       await user.reauthenticateWithCredential(cred);
//     }
//     await user.delete();
//     await _googleSignIn.signOut();
//   }
//
//   /// Delete Google account (no password needed)
//   Future<void> deleteGoogleAccount() async {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('Not signed in');
//     final googleUser = await _googleSignIn.signIn();
//     if (googleUser == null) throw Exception('Google sign-in cancelled');
//     final googleAuth = await googleUser.authentication;
//     final cred = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
//     await user.reauthenticateWithCredential(cred);
//     await user.delete();
//     await _googleSignIn.signOut();
//   }
//
//   bool get isGoogleUser =>
//       _auth.currentUser?.providerData
//           .any((p) => p.providerId == 'google.com') ??
//           false;
//
//   String getFriendlyError(String code) {
//     switch (code) {
//       case 'user-not-found':        return 'No account found with this email.';
//       case 'wrong-password':
//       case 'invalid-credential':    return 'Incorrect email or password.';
//       case 'email-already-in-use':  return 'This email is already registered.';
//       case 'invalid-email':         return 'Please enter a valid email address.';
//       case 'weak-password':         return 'Password must be at least 6 characters.';
//       case 'too-many-requests':     return 'Too many attempts. Wait and try again.';
//       case 'network-request-failed':return 'Network error. Check your internet.';
//       case 'requires-recent-login': return 'Please sign out and sign in again first.';
//       case 'google-sign-in-failed': return 'Google Sign-In failed. Add SHA-1 in Firebase Console.';
//       default: return 'Something went wrong ($code). Please try again.';
//     }
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    await _googleSignIn.signOut();
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    if (googleAuth.accessToken == null && googleAuth.idToken == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google authentication failed. Add SHA-1 in Firebase Console.',
      );
    }
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user?.updateDisplayName(displayName.trim());
    // reload so currentUser.displayName is immediately available
    await cred.user?.reload();
    return cred;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name.trim());
    await _auth.currentUser?.reload();
  }

  /// Change password — requires recent login
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    if (user.email == null) throw Exception('No email on account');

    // Re-authenticate first
    final cred = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  /// Delete account — requires re-authentication
  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');

    if (user.email != null) {
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
    }
    await user.delete();
    await _googleSignIn.signOut();
  }

  /// Delete Google account (no password needed)
  Future<void> deleteGoogleAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');
    final googleAuth = await googleUser.authentication;
    final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    await user.reauthenticateWithCredential(cred);
    await user.delete();
    await _googleSignIn.signOut();
  }

  /// Send password reset email — Firebase handles the rest
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  bool get isGoogleUser =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'google.com') ??
          false;

  String getFriendlyError(String code) {
    switch (code) {
      case 'user-not-found':        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':    return 'Incorrect email or password.';
      case 'email-already-in-use':  return 'This email is already registered.';
      case 'invalid-email':         return 'Please enter a valid email address.';
      case 'weak-password':         return 'Password must be at least 6 characters.';
      case 'too-many-requests':     return 'Too many attempts. Wait and try again.';
      case 'network-request-failed':return 'Network error. Check your internet.';
      case 'requires-recent-login': return 'Please sign out and sign in again first.';
      case 'google-sign-in-failed': return 'Google Sign-In failed. Add SHA-1 in Firebase Console.';
      default: return 'Something went wrong ($code). Please try again.';
    }
  }
}