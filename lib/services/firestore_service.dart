import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/level_progress.dart';
import '../models/leaderboard_entry.dart';

/// All Firestore CRUD operations for users, progress, and leaderboards.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── User Profile ──────────────────────────────────────────

  Future<void> createOrUpdateUser(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<UserProfile?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!);
  }

  /// Pick a unique 4-digit tag (0000-9999) for a given username.
  /// We just retry random numbers a few times — collisions are unlikely.
  Future<int> reserveUsernameTag(String username) async {
    final rng = DateTime.now().microsecondsSinceEpoch;
    for (int attempt = 0; attempt < 20; attempt++) {
      final tag = ((rng + attempt * 7919) % 10000).abs();
      final key = '${username.toLowerCase()}#${tag.toString().padLeft(4, '0')}';
      final ref = _db.collection('usernames').doc(key);
      try {
        final ok = await _db.runTransaction<bool>((tx) async {
          final snap = await tx.get(ref);
          if (snap.exists) return false;
          tx.set(ref, {'taken': true, 'createdAt': FieldValue.serverTimestamp()});
          return true;
        });
        if (ok) return tag;
      } catch (_) {
        // try next
      }
    }
    throw Exception('Could not allocate a unique username tag, please try again.');
  }

  /// Update the global undo count on the user document.
  Future<void> updateUndosRemaining(String uid, int count) async {
    await _db.collection('users').doc(uid).update({
      'undosRemaining': count,
    });
  }

  // ── Level Progress ────────────────────────────────────────

  Future<void> saveLevelProgress(
      String uid, LevelProgress progress) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(progress.levelId)
        .set(progress.toMap(), SetOptions(merge: true));
  }

  Future<LevelProgress?> getLevelProgress(
      String uid, String levelId) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(levelId)
        .get();
    if (!doc.exists) return null;
    return LevelProgress.fromMap(doc.data()!);
  }

  Future<void> deleteAllProgress(String uid) async {
    final col = _db.collection('users').doc(uid).collection('progress');
    final snap = await col.get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    try {
      await _db.collection('users').doc(uid).update({
        'levelsCompleted': 0,
        'totalStars': 0,
      });
    } catch (_) {}
  }

  Future<Map<String, LevelProgress>> getAllProgress(String uid) async {
    final snapshot =
        await _db.collection('users').doc(uid).collection('progress').get();
    final map = <String, LevelProgress>{};
    for (final doc in snapshot.docs) {
      final progress = LevelProgress.fromMap(doc.data());
      map[progress.levelId] = progress;
    }
    return map;
  }

  /// Update aggregate stats on the user document.
  Future<void> updateUserStats(String uid) async {
    final progress = await getAllProgress(uid);
    final completed =
        progress.values.where((p) => p.completed).length;
    final totalStars =
        progress.values.fold<int>(0, (total, p) => total + p.stars);

    await _db.collection('users').doc(uid).update({
      'levelsCompleted': completed,
      'totalStars': totalStars,
    });
  }

  /// Delete all user data (profile + progress).
  Future<void> deleteUserData(String uid) async {
    // Delete user profile
    await _db.collection('users').doc(uid).delete();
    // Delete all progress
    await deleteAllProgress(uid);
  }

  // ── Leaderboards ──────────────────────────────────────────

  Future<void> submitLeaderboardEntry(LeaderboardEntry entry) async {
    final docRef = _db
        .collection('leaderboards')
        .doc(entry.levelId)
        .collection('entries')
        .doc(entry.uid);

    // Only update if this is a better score
    final existing = await docRef.get();
    if (existing.exists) {
      final existingMoves = existing.data()!['moves'] as int;
      if (entry.moves >= existingMoves) return; // Not a better score
    }

    await docRef.set(entry.toMap());
  }

  Future<List<LeaderboardEntry>> getLeaderboard(String levelId,
      {int limit = 50}) async {
    final snapshot = await _db
        .collection('leaderboards')
        .doc(levelId)
        .collection('entries')
        .orderBy('moves')
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => LeaderboardEntry.fromMap(doc.data()))
        .toList();
  }

  /// Get global leaderboard by total stars.
  Future<List<UserProfile>> getGlobalLeaderboard({int limit = 50}) async {
    final snapshot = await _db
        .collection('users')
        .orderBy('totalStars', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => UserProfile.fromMap(doc.data()))
        .toList();
  }
}
