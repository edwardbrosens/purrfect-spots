import 'package:cloud_firestore/cloud_firestore.dart';

class LevelProgress {
  final String levelId;
  final bool completed;
  final int stars;
  final int bestMoves;
  final int attempts;
  final int undosUsed;
  final int? undosRemaining; // persisted per level across sessions
  final DateTime lastPlayedAt;

  const LevelProgress({
    required this.levelId,
    this.completed = false,
    this.stars = 0,
    this.bestMoves = 0,
    this.attempts = 0,
    this.undosUsed = 0,
    this.undosRemaining,
    required this.lastPlayedAt,
  });

  Map<String, dynamic> toMap() => {
        'levelId': levelId,
        'completed': completed,
        'stars': stars,
        'bestMoves': bestMoves,
        'attempts': attempts,
        'undosUsed': undosUsed,
        'undosRemaining': undosRemaining,
        'lastPlayedAt': Timestamp.fromDate(lastPlayedAt),
      };

  factory LevelProgress.fromMap(Map<String, dynamic> map) => LevelProgress(
        levelId: map['levelId'] as String,
        completed: map['completed'] as bool? ?? false,
        stars: map['stars'] as int? ?? 0,
        bestMoves: map['bestMoves'] as int? ?? 0,
        attempts: map['attempts'] as int? ?? 0,
        undosUsed: map['undosUsed'] as int? ?? 0,
        undosRemaining: map['undosRemaining'] as int?,
        lastPlayedAt: (map['lastPlayedAt'] as Timestamp).toDate(),
      );

  LevelProgress copyWith({
    bool? completed,
    int? stars,
    int? bestMoves,
    int? attempts,
    int? undosUsed,
    int? undosRemaining,
    DateTime? lastPlayedAt,
  }) =>
      LevelProgress(
        levelId: levelId,
        completed: completed ?? this.completed,
        stars: stars ?? this.stars,
        bestMoves: bestMoves ?? this.bestMoves,
        attempts: attempts ?? this.attempts,
        undosUsed: undosUsed ?? this.undosUsed,
        undosRemaining: undosRemaining ?? this.undosRemaining,
        lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      );
}
