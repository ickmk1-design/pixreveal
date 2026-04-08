class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final bool isAnonymous;
  final bool isPremium;
  final int totalStars;
  final int levelsCompleted;

  const UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.isAnonymous = true,
    this.isPremium = false,
    this.totalStars = 0,
    this.levelsCompleted = 0,
  });

  UserModel copyWith({
    String? displayName,
    String? email,
    bool? isAnonymous,
    bool? isPremium,
    int? totalStars,
    int? levelsCompleted,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPremium: isPremium ?? this.isPremium,
      totalStars: totalStars ?? this.totalStars,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
    );
  }
}
