import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final int? usernameTag; // 4-digit unique discriminator (e.g. #0421)
  final String? avatarUrl;
  final String authProvider;
  final DateTime createdAt;
  final int totalStars;
  final int levelsCompleted;
  final int undosRemaining;
  final bool adsDisabled; // admin toggle in Firestore
  final DateTime? premiumUntil; // null = not premium

  const UserProfile({
    required this.uid,
    this.displayName,
    this.usernameTag,
    this.avatarUrl,
    required this.authProvider,
    required this.createdAt,
    this.totalStars = 0,
    this.levelsCompleted = 0,
    this.undosRemaining = 10,
    this.adsDisabled = false,
    this.premiumUntil,
  });

  bool get isPremium =>
      premiumUntil != null && premiumUntil!.isAfter(DateTime.now());

  bool get showAds => !adsDisabled && !isPremium;

  /// Username with tag, e.g. "Whiskers#0421". Used in account details only.
  String get fullHandle =>
      usernameTag == null
          ? (displayName ?? 'Cat Lover')
          : '${displayName ?? 'Cat Lover'}#${usernameTag.toString().padLeft(4, '0')}';

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'usernameTag': usernameTag,
        'avatarUrl': avatarUrl,
        'authProvider': authProvider,
        'createdAt': Timestamp.fromDate(createdAt),
        'totalStars': totalStars,
        'levelsCompleted': levelsCompleted,
        'undosRemaining': undosRemaining,
        'adsDisabled': adsDisabled,
        'premiumUntil':
            premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        uid: map['uid'] as String,
        displayName: map['displayName'] as String?,
        usernameTag: map['usernameTag'] as int?,
        avatarUrl: map['avatarUrl'] as String?,
        authProvider: map['authProvider'] as String,
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        totalStars: map['totalStars'] as int? ?? 0,
        levelsCompleted: map['levelsCompleted'] as int? ?? 0,
        undosRemaining: map['undosRemaining'] as int? ?? 10,
        adsDisabled: map['adsDisabled'] as bool? ?? false,
        premiumUntil: map['premiumUntil'] != null
            ? (map['premiumUntil'] as Timestamp).toDate()
            : null,
      );

  UserProfile copyWith({
    String? displayName,
    int? usernameTag,
    String? avatarUrl,
    String? authProvider,
    int? totalStars,
    int? levelsCompleted,
    int? undosRemaining,
    bool? adsDisabled,
    DateTime? premiumUntil,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName ?? this.displayName,
        usernameTag: usernameTag ?? this.usernameTag,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        authProvider: authProvider ?? this.authProvider,
        createdAt: createdAt,
        totalStars: totalStars ?? this.totalStars,
        levelsCompleted: levelsCompleted ?? this.levelsCompleted,
        undosRemaining: undosRemaining ?? this.undosRemaining,
        adsDisabled: adsDisabled ?? this.adsDisabled,
        premiumUntil: premiumUntil ?? this.premiumUntil,
      );
}
