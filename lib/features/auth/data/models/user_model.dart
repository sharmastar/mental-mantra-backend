// lib/features/auth/data/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? role;
  final bool emailVerified;
  final bool onboardingCompleted;
  final int streakDays;
  final int totalPoints;
  final int level;
  final String? nickname;
  final int? age;
  final String? gender;
  final String? country;
  final String? relationshipStatus;
  final String? livingSituation;
  final String? occupation;
  final String? ageGroup;
  final DateTime? createdAt;
  final DateTime? lastActive;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'user',
    this.emailVerified = false,
    this.onboardingCompleted = false,
    this.streakDays = 0,
    this.totalPoints = 0,
    this.level = 1,
    this.nickname,
    this.age,
    this.gender,
    this.country,
    this.relationshipStatus,
    this.livingSituation,
    this.occupation,
    this.ageGroup,
    this.createdAt,
    this.lastActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String? ?? 'user',
      emailVerified: json['emailVerified'] as bool? ?? false,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      streakDays: json['streakDays'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      nickname: json['nickname'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
      relationshipStatus: json['relationshipStatus'] as String?,
      livingSituation: json['livingSituation'] as String?,
      occupation: json['occupation'] as String?,
      ageGroup: json['ageGroup'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role,
        'emailVerified': emailVerified,
        'onboardingCompleted': onboardingCompleted,
        'streakDays': streakDays,
        'totalPoints': totalPoints,
        'level': level,
        'nickname': nickname,
        'age': age,
        'gender': gender,
        'country': country,
        'relationshipStatus': relationshipStatus,
        'livingSituation': livingSituation,
        'occupation': occupation,
        'ageGroup': ageGroup,
        'createdAt': createdAt?.toIso8601String(),
        'lastActive': lastActive?.toIso8601String(),
      };

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    bool? emailVerified,
    bool? onboardingCompleted,
    int? streakDays,
    int? totalPoints,
    int? level,
    String? nickname,
    int? age,
    String? gender,
    String? country,
    String? relationshipStatus,
    String? livingSituation,
    String? occupation,
    String? ageGroup,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      streakDays: streakDays ?? this.streakDays,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      livingSituation: livingSituation ?? this.livingSituation,
      occupation: occupation ?? this.occupation,
      ageGroup: ageGroup ?? this.ageGroup,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
