import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final String? avatarUrl;
  final String authProvider;
  final DateTime createdAt;
  final int totalStars;
  final int levelsCompleted;

  const UserProfile({
    required this.uid,
    this.displayName,
    this.avatarUrl,
    required this.authProvider,
    required this.createdAt,
    this.totalStars = 0,
    this.levelsCompleted = 0,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'authProvider': authProvider,
        'createdAt': Timestamp.fromDate(createdAt),
        'totalStars': totalStars,
        'levelsCompleted': levelsCompleted,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String?,
        avatarUrl: map['avatarUrl'] as String?,
        authProvider: map['authProvider'] as String,
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        totalStars: map['totalStars'] as int? ?? 0,
        levelsCompleted: map['levelsCompleted'] as int? ?? 0,
      );

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? authProvider,
    int? totalStars,
    int? levelsCompleted,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        authProvider: authProvider ?? this.authProvider,
        createdAt: createdAt,
        totalStars: totalStars ?? this.totalStars,
        levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      );
}
