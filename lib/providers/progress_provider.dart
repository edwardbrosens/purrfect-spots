import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_progress.dart';
import '../models/leaderboard_entry.dart';
import '../services/firestore_service.dart';

/// Manages user progress, syncs with Firestore + local cache.
class ProgressProvider extends ChangeNotifier {
  final bool firebaseReady;
  late final FirestoreService _firestoreService;
  final Map<String, LevelProgress> _progress = {};
  String? _uid;

  ProgressProvider({this.firebaseReady = true}) {
    if (firebaseReady) {
      _firestoreService = FirestoreService();
    }
  }

  Map<String, LevelProgress> get progress => Map.unmodifiable(_progress);

  /// Initialize with a user ID and load progress.
  /// Safe to call again when the signed-in user changes.
  Future<void> initialize(String uid) async {
    _uid = uid;
    _progress.clear();

    // Always try local cache first (keyed per user so accounts don't leak)
    await _loadFromLocal(uid);

    // Then try Firestore if available — cloud is source of truth when present
    if (firebaseReady) {
      try {
        final cloudProgress = await _firestoreService.getAllProgress(uid);
        if (cloudProgress.isNotEmpty) {
          _progress
            ..clear()
            ..addAll(cloudProgress);
          // Refresh local cache from cloud
          for (final entry in cloudProgress.entries) {
            await _saveToLocal(entry.key, entry.value);
          }
        }
      } catch (e) {
        debugPrint('Firestore load failed, using local cache: $e');
      }
    }
    notifyListeners();
  }

  /// Get progress for a specific level.
  LevelProgress? getLevelProgress(String levelId) => _progress[levelId];

  /// Check if a level is unlocked. Level 1 is always unlocked.
  /// Other levels require the previous level to be completed.
  bool isLevelUnlocked(int floor) {
    if (floor <= 1) return true;
    for (final entry in _progress.entries) {
      if (entry.value.completed) {
        final match = RegExp(r'floor_(\d+)').firstMatch(entry.key);
        if (match != null) {
          final completedFloor = int.parse(match.group(1)!);
          if (completedFloor >= floor - 1) return true;
        }
      }
    }
    return floor <= 1;
  }

  /// Save level completion.
  Future<void> saveLevelComplete({
    required String levelId,
    required int moves,
    required int stars,
    required int undosUsed,
    required String displayName,
  }) async {
    final existing = _progress[levelId];
    final attempts = (existing?.attempts ?? 0) + 1;

    final newProgress = LevelProgress(
      levelId: levelId,
      completed: true,
      stars: existing != null && existing.stars > stars
          ? existing.stars
          : stars,
      bestMoves: existing != null &&
              existing.bestMoves > 0 &&
              existing.bestMoves < moves
          ? existing.bestMoves
          : moves,
      attempts: attempts,
      undosUsed: undosUsed,
      lastPlayedAt: DateTime.now(),
    );

    _progress[levelId] = newProgress;
    notifyListeners();

    // Save to local cache (always)
    await _saveToLocal(levelId, newProgress);

    // Sync to Firestore if available
    if (firebaseReady && _uid != null) {
      try {
        await _firestoreService.saveLevelProgress(_uid!, newProgress);
        await _firestoreService.updateUserStats(_uid!);

        await _firestoreService.submitLeaderboardEntry(LeaderboardEntry(
          uid: _uid!,
          displayName: displayName,
          levelId: levelId,
          moves: moves,
          timestamp: DateTime.now(),
        ));
      } catch (e) {
        debugPrint('Failed to sync progress: $e');
      }
    }
  }

  /// Record an attempt (even if not completed).
  Future<void> recordAttempt(String levelId) async {
    final existing = _progress[levelId];
    final newProgress = LevelProgress(
      levelId: levelId,
      completed: existing?.completed ?? false,
      stars: existing?.stars ?? 0,
      bestMoves: existing?.bestMoves ?? 0,
      attempts: (existing?.attempts ?? 0) + 1,
      undosUsed: existing?.undosUsed ?? 0,
      lastPlayedAt: DateTime.now(),
    );

    _progress[levelId] = newProgress;
  }

  /// Delete ALL progress for the current user — local cache and cloud.
  Future<void> resetAllProgress() async {
    _progress.clear();
    notifyListeners();

    // Wipe this user's local keys
    final prefs = await SharedPreferences.getInstance();
    if (_uid != null) {
      final prefix = _prefix(_uid!);
      final toDelete =
          prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
      for (final k in toDelete) {
        await prefs.remove(k);
      }
    }

    // Wipe Firestore docs
    if (firebaseReady && _uid != null) {
      try {
        await _firestoreService.deleteAllProgress(_uid!);
      } catch (e) {
        debugPrint('Failed to wipe cloud progress: $e');
      }
    }
  }

  int get totalStars =>
      _progress.values.fold<int>(0, (total, p) => total + p.stars);

  int get levelsCompleted =>
      _progress.values.where((p) => p.completed).length;

  // ── Local Cache (keyed per user so sign-in/out doesn't leak state) ──

  String _prefix(String uid) => 'progress_${uid}_';

  Future<void> _saveToLocal(String levelId, LevelProgress progress) async {
    if (_uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    final p = '${_prefix(_uid!)}$levelId';
    await prefs.setBool('${p}_completed', progress.completed);
    await prefs.setInt('${p}_stars', progress.stars);
    await prefs.setInt('${p}_bestMoves', progress.bestMoves);
    await prefs.setInt('${p}_attempts', progress.attempts);
    await prefs.setInt('${p}_undosUsed', progress.undosUsed);
    await prefs.setInt(
        '${p}_lastPlayedAt', progress.lastPlayedAt.millisecondsSinceEpoch);
  }

  Future<void> _loadFromLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _prefix(uid);
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix));
    final levelIds = <String>{};
    for (final key in keys) {
      final rest = key.substring(prefix.length);
      final idx = rest.lastIndexOf('_');
      if (idx > 0) levelIds.add(rest.substring(0, idx));
    }

    for (final levelId in levelIds) {
      final p = '$prefix$levelId';
      _progress[levelId] = LevelProgress(
        levelId: levelId,
        completed: prefs.getBool('${p}_completed') ?? false,
        stars: prefs.getInt('${p}_stars') ?? 0,
        bestMoves: prefs.getInt('${p}_bestMoves') ?? 0,
        attempts: prefs.getInt('${p}_attempts') ?? 0,
        undosUsed: prefs.getInt('${p}_undosUsed') ?? 0,
        lastPlayedAt: DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt('${p}_lastPlayedAt') ??
                DateTime.now().millisecondsSinceEpoch),
      );
    }
  }
}
