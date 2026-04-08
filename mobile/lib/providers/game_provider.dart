import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameStatus { playing, paused, won, lost, idle }

class GameState {
  final int currentLevel;
  final double capturedPercent;
  final int lives;
  final int stars;
  final int elapsedSeconds;
  final GameStatus status;

  const GameState({
    this.currentLevel = 1,
    this.capturedPercent = 0,
    this.lives = 3,
    this.stars = 0,
    this.elapsedSeconds = 0,
    this.status = GameStatus.idle,
  });

  GameState copyWith({
    int? currentLevel,
    double? capturedPercent,
    int? lives,
    int? stars,
    int? elapsedSeconds,
    GameStatus? status,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      capturedPercent: capturedPercent ?? this.capturedPercent,
      lives: lives ?? this.lives,
      stars: stars ?? this.stars,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
    );
  }

  int calculateStars(double captured) {
    if (captured >= 0.95) return 3;
    if (captured >= 0.90) return 2;
    if (captured >= 0.80) return 1;
    return 0;
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(const GameState());

  void startLevel(int levelId, int lives) {
    state = GameState(
      currentLevel: levelId,
      lives: lives,
      status: GameStatus.playing,
    );
  }

  void updateCapture(double percent) {
    state = state.copyWith(capturedPercent: percent);
    if (percent >= 0.80) {
      final stars = state.calculateStars(percent);
      state = state.copyWith(status: GameStatus.won, stars: stars);
    }
  }

  void loseLife() {
    final newLives = state.lives - 1;
    if (newLives <= 0) {
      state = state.copyWith(lives: 0, status: GameStatus.lost);
    } else {
      state = state.copyWith(lives: newLives);
    }
  }

  void pause() {
    if (state.status == GameStatus.playing) {
      state = state.copyWith(status: GameStatus.paused);
    }
  }

  void resume() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
    }
  }

  void tick() {
    state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }

  void reset() {
    state = const GameState();
  }
}
