import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final String levelId;
  final int moves;
  final DateTime timestamp;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.levelId,
    required this.moves,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'levelId': levelId,
        'moves': moves,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) =>
      LeaderboardEntry(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String,
        levelId: map['levelId'] as String,
        moves: map['moves'] as int,
        timestamp: (map['timestamp'] as Timestamp).toDate(),
      );
}
