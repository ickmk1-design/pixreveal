import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  final int score;
  final int level;
  final int tokens;
  final int lives;
  final double capturedPercent;

  const GameState({
    this.score = 0,
    this.level = 1,
    this.tokens = 5,
    this.lives = 3,
    this.capturedPercent = 0.0,
  });

  GameState copyWith({
    int? score,
    int? level,
    int? tokens,
    int? lives,
    double? capturedPercent,
  }) =>
      GameState(
        score: score ?? this.score,
        level: level ?? this.level,
        tokens: tokens ?? this.tokens,
        lives: lives ?? this.lives,
        capturedPercent: capturedPercent ?? this.capturedPercent,
      );
}

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() => const GameState();

  void addScore(int pts) => state = state.copyWith(score: state.score + pts);
  void loseLife() => state = state.copyWith(lives: state.lives - 1);
  void useToken() => state = state.copyWith(tokens: state.tokens - 1, lives: 3);
  void nextLevel() => state = state.copyWith(level: state.level + 1);
  void setCaptured(double pct) => state = state.copyWith(capturedPercent: pct);
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
