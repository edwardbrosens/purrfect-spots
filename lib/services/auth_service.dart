import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps Firebase Auth — anonymous + Google sign-in with account linking.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// Sign in anonymously (first launch).
  Future<User?> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  /// Sign in with Google, linking to anonymous account if possible.
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Try to link to existing anonymous account
      if (_auth.currentUser?.isAnonymous == true) {
        try {
          final result =
              await _auth.currentUser!.linkWithCredential(credential);
          return result.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            // Google account already exists — sign in directly
            final result = await _auth.signInWithCredential(credential);
            return result.user;
          }
          rethrow;
        }
      }

      // Not anonymous — just sign in
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on GoogleSignInException {
      // User cancelled or other sign-in error
      return null;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    // Re-create anonymous session
    await signInAnonymously();
  }
}
