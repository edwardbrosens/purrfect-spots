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
