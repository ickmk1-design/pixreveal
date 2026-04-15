import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenState {
  final int tokens;

  const TokenState({required this.tokens});
}

final tokenProvider = Provider<TokenState>((ref) {
  return const TokenState(tokens: 1250);
});
