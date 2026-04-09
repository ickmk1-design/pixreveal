class TokenModel {
  final int tokens;
  final int lives;
  final int adsWatchedToday;
  final DateTime? lastDailyLogin;

  const TokenModel({
    this.tokens = 10,
    this.lives = 3,
    this.adsWatchedToday = 0,
    this.lastDailyLogin,
  });

  bool get canWatchAd => adsWatchedToday < 10;

  bool get hasDailyLoginAvailable {
    if (lastDailyLogin == null) return true;
    final now = DateTime.now();
    return now.day != lastDailyLogin!.day ||
        now.month != lastDailyLogin!.month ||
        now.year != lastDailyLogin!.year;
  }

  TokenModel copyWith({
    int? tokens,
    int? lives,
    int? adsWatchedToday,
    DateTime? lastDailyLogin,
  }) {
    return TokenModel(
      tokens: tokens ?? this.tokens,
      lives: lives ?? this.lives,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
      lastDailyLogin: lastDailyLogin ?? this.lastDailyLogin,
    );
  }

  Map<String, dynamic> toJson() => {
        'tokens': tokens,
        'lives': lives,
        'adsWatchedToday': adsWatchedToday,
        'lastDailyLogin': lastDailyLogin?.toIso8601String(),
      };

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        tokens: json['tokens'] ?? 5,
        lives: json['lives'] ?? 3,
        adsWatchedToday: json['adsWatchedToday'] ?? 0,
        lastDailyLogin: json['lastDailyLogin'] != null
            ? DateTime.parse(json['lastDailyLogin'])
            : null,
      );
}
