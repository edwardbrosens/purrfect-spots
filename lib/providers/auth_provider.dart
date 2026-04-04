import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final bool firebaseReady;

  late final AuthService _authService;
  late final FirestoreService _firestoreService;

  User? _user;
  UserProfile? _profile;
  bool _isLoading = false;
  final String _offlineUid = 'local_user';

  AuthProvider({this.firebaseReady = true}) {
    if (firebaseReady) {
      _authService = AuthService();
      _firestoreService = FirestoreService();
    }
  }

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSignedIn => firebaseReady ? _user != null : true;
  bool get isAnonymous => firebaseReady ? (_user?.isAnonymous ?? true) : true;
  String get uid => _user?.uid ?? _offlineUid;
  String get displayName =>
      _profile?.displayName ?? _user?.displayName ?? 'Cat Lover';

  /// Initialize auth state — call once on app start.
  Future<void> initialize() async {
    if (!firebaseReady) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        try {
          _profile = await _firestoreService.getUser(user.uid);
          if (_profile == null) {
            _profile = UserProfile(
              uid: user.uid,
              displayName: user.displayName,
              avatarUrl: user.photoURL,
              authProvider: user.isAnonymous ? 'anonymous' : 'google',
              createdAt: DateTime.now(),
            );
            await _firestoreService.createOrUpdateUser(_profile!);
          }
        } catch (e) {
          debugPrint('Firestore error: $e');
        }
      }
      _isLoading = false;
      notifyListeners();
    });

    // Sign in anonymously if not already signed in
    try {
      if (_authService.currentUser == null) {
        await _authService.signInAnonymously();
      } else {
        _user = _authService.currentUser;
      }
    } catch (e) {
      debugPrint('Auth sign-in failed: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    if (!firebaseReady) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (!firebaseReady) return;
    await _authService.signOut();
  }
}
