import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

/// Wraps Firebase Auth — anonymous + Google sign-in with account linking.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// Sign in anonymously (first launch).
  Future<User?> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  /// Sign in with Google, linking to anonymous account if possible.
  /// Uses FirebaseAuth's built-in OAuth flow (popup on web, Custom Tabs on
  /// Android/iOS), which doesn't require a serverClientId to be configured.
  Future<User?> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      Future<UserCredential> doSignIn() async {
        if (kIsWeb) {
          return _auth.signInWithPopup(provider);
        }
        return _auth.signInWithProvider(provider);
      }

      Future<UserCredential> doLink() async {
        if (kIsWeb) {
          return _auth.currentUser!.linkWithPopup(provider);
        }
        return _auth.currentUser!.linkWithProvider(provider);
      }

      if (_auth.currentUser?.isAnonymous == true) {
        try {
          final result = await doLink();
          return result.user;
        } on FirebaseAuthException catch (e) {
          if (e.code != 'credential-already-in-use' &&
              e.code != 'email-already-in-use') {
            rethrow;
          }
          // Fall through and sign in directly
        }
      }

      final result = await doSignIn();
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Google auth failed: ${e.code} ${e.message}');
      if (e.code == 'web-context-canceled' ||
          e.code == 'popup-closed-by-user' ||
          e.code == 'user-cancelled') {
        return null;
      }
      rethrow;
    } catch (e) {
      debugPrint('signInWithGoogle error: $e');
      rethrow;
    }
  }

  /// Generate a cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// SHA-256 hash of a string, returned as a hex string.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in with Apple, linking to anonymous account if possible.
  Future<User?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      if (_auth.currentUser?.isAnonymous == true) {
        try {
          final result =
              await _auth.currentUser!.linkWithCredential(oauthCredential);
          return result.user;
        } on FirebaseAuthException catch (e) {
          if (e.code != 'credential-already-in-use' &&
              e.code != 'email-already-in-use') {
            rethrow;
          }
          // Fall through and sign in directly
        }
      }

      final result = await _auth.signInWithCredential(oauthCredential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Apple auth failed: ${e.code} ${e.message}');
      if (e.code == 'web-context-canceled' ||
          e.code == 'popup-closed-by-user' ||
          e.code == 'user-cancelled') {
        return null;
      }
      rethrow;
    } catch (e) {
      if (e.toString().contains('AuthorizationErrorCode.canceled')) {
        return null;
      }
      debugPrint('signInWithApple error: $e');
      rethrow;
    }
  }

  /// Create a new account with email + password.
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // If currently anonymous, link the credential to preserve the uid.
    if (_auth.currentUser?.isAnonymous == true) {
      try {
        final cred = EmailAuthProvider.credential(email: email, password: password);
        final result = await _auth.currentUser!.linkWithCredential(cred);
        return result.user;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'credential-already-in-use' &&
            e.code != 'email-already-in-use') {
          rethrow;
        }
        // Fall through to direct sign-up
      }
    }
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Sign in with email + password.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
    // Re-create anonymous session
    await signInAnonymously();
  }

  /// Delete the current user account from Firebase Auth.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
