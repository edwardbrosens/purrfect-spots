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
  Future<void> initialize(String uid) async {
    _uid = uid;

    // Always try local cache first
    await _loadFromLocal();

    // Then try Firestore if available
    if (firebaseReady) {
      try {
        final cloudProgress = await _firestoreService.getAllProgress(uid);
        _progress.addAll(cloudProgress);
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

  int get totalStars =>
      _progress.values.fold<int>(0, (total, p) => total + p.stars);

  int get levelsCompleted =>
      _progress.values.where((p) => p.completed).length;

  // ── Local Cache ──────────────────────────────────────────

  Future<void> _saveToLocal(String levelId, LevelProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('progress_${levelId}_completed', progress.completed);
    await prefs.setInt('progress_${levelId}_stars', progress.stars);
    await prefs.setInt('progress_${levelId}_bestMoves', progress.bestMoves);
    await prefs.setInt('progress_${levelId}_attempts', progress.attempts);
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('progress_'));
    final levelIds = <String>{};
    for (final key in keys) {
      final match = RegExp(r'progress_(.+?)_').firstMatch(key);
      if (match != null) levelIds.add(match.group(1)!);
    }

    for (final levelId in levelIds) {
      _progress[levelId] = LevelProgress(
        levelId: levelId,
        completed: prefs.getBool('progress_${levelId}_completed') ?? false,
        stars: prefs.getInt('progress_${levelId}_stars') ?? 0,
        bestMoves: prefs.getInt('progress_${levelId}_bestMoves') ?? 0,
        attempts: prefs.getInt('progress_${levelId}_attempts') ?? 0,
        lastPlayedAt: DateTime.now(),
      );
    }
  }
}
