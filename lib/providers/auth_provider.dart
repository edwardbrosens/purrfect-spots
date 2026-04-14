import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';

// Re-export so screens that import this provider get UserProfile too if needed.
export '../models/user_profile.dart';

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
  int get undosRemaining => _profile?.undosRemaining ?? 10;
  bool get isPremium => _profile?.isPremium ?? false;
  bool get showAds => _profile?.showAds ?? true;
  bool get adsDisabled => _profile?.adsDisabled ?? false;

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

  Future<String?> signInWithGoogle({String? username}) async {
    if (!firebaseReady) return 'Firebase not ready';

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) return 'Sign-in cancelled';
      _user = user; // Update immediately so uid is correct downstream
      final name = (username != null && username.trim().isNotEmpty)
          ? username.trim()
          : (user.displayName ?? user.email?.split('@').first ?? 'Cat Lover');
      await _ensureProfile(user, name, 'google');
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithApple({String? username}) async {
    if (!firebaseReady) return 'Firebase not ready';

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithApple();
      if (user == null) return 'Sign-in cancelled';
      _user = user;
      final name = (username != null && username.trim().isNotEmpty)
          ? username.trim()
          : (user.displayName ?? user.email?.split('@').first ?? 'Cat Lover');
      await _ensureProfile(user, name, 'apple');
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    if (!firebaseReady) return 'Firebase not ready';
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.signUpWithEmail(email: email, password: password);
      if (user != null) {
        await _ensureProfile(user, username.trim(), 'password');
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!firebaseReady) return 'Firebase not ready';
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.signInWithEmail(email: email, password: password);
      if (user != null) _user = user;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? e.code;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureProfile(User user, String username, String provider) async {
    try {
      var existing = await _firestoreService.getUser(user.uid);
      if (existing != null && existing.usernameTag != null) {
        _profile = existing;
        return;
      }
      final tag = await _firestoreService.reserveUsernameTag(username);
      final profile = UserProfile(
        uid: user.uid,
        displayName: username,
        usernameTag: tag,
        avatarUrl: user.photoURL,
        authProvider: provider,
        createdAt: existing?.createdAt ?? DateTime.now(),
      );
      await _firestoreService.createOrUpdateUser(profile);
      _profile = profile;
    } catch (e) {
      debugPrint('ensureProfile failed: $e');
    }
  }

  /// Update the global undo count (after using an undo or earning more).
  Future<void> setUndosRemaining(int count) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(undosRemaining: count);
    notifyListeners();

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('undos_${_profile!.uid}', count);

    // Sync to Firestore
    if (firebaseReady) {
      try {
        await _firestoreService.updateUndosRemaining(_profile!.uid, count);
      } catch (e) {
        debugPrint('Failed to sync undos to cloud: $e');
      }
    }
  }

  /// Add undos (e.g. from watching a rewarded ad).
  Future<void> addUndos(int count) async {
    await setUndosRemaining(undosRemaining + count);
  }

  /// Spend one undo.
  Future<void> spendUndo() async {
    if (undosRemaining > 0) {
      await setUndosRemaining(undosRemaining - 1);
    }
  }

  /// Activate premium subscription (called after verified purchase).
  Future<void> activatePremium() async {
    if (_profile == null) return;
    final until = DateTime.now().add(const Duration(days: 31));
    _profile = _profile!.copyWith(premiumUntil: until);
    notifyListeners();

    if (firebaseReady) {
      try {
        await _firestoreService.createOrUpdateUser(_profile!);
      } catch (e) {
        debugPrint('Failed to sync premium status: $e');
      }
    }
  }

  Future<void> signOut() async {
    if (!firebaseReady) return;
    await _authService.signOut();
  }

  /// Permanently delete the user's account and all associated data.
  Future<String?> deleteAccount() async {
    if (!firebaseReady || _user == null) return 'Not signed in';
    try {
      final uid = _user!.uid;
      await _firestoreService.deleteUserData(uid);
      await _authService.deleteAccount();
      _user = null;
      _profile = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
