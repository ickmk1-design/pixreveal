import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/iap_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final iapServiceProvider = Provider<IAPService>((ref) => IAPService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

class UserState {
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;
  final bool isAnonymous;
  final String? displayName;
  final String? email;
  final String? uid;
  final String provider;
  final bool isPremium;
  final bool isAdFree;
  final bool hasCustomImage;
  final bool termsAccepted;

  const UserState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
    this.isAnonymous = true,
    this.displayName,
    this.email,
    this.uid,
    this.provider = 'None',
    this.isPremium = false,
    this.isAdFree = false,
    this.hasCustomImage = false,
    this.termsAccepted = false,
  });

  UserState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
    bool? isAnonymous,
    String? displayName,
    String? email,
    String? uid,
    String? provider,
    bool? isPremium,
    bool? isAdFree,
    bool? hasCustomImage,
    bool? termsAccepted,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      provider: provider ?? this.provider,
      isPremium: isPremium ?? this.isPremium,
      isAdFree: isAdFree ?? this.isAdFree,
      hasCustomImage: hasCustomImage ?? this.hasCustomImage,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;

  UserNotifier(this.ref) : super(const UserState());

  AuthService get _auth => ref.read(authServiceProvider);
  IAPService get _iap => ref.read(iapServiceProvider);

  void acceptTerms() {
    state = state.copyWith(termsAccepted: true);
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true);
    try {
      await _auth.signInAnonymously();
      await _syncUser();
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    try {
      await _auth.signInWithGoogle();
      await _syncUser();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true);
    try {
      await _auth.signInWithApple();
      await _syncUser();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _auth.signInWithEmail(email, password);
      await _syncUser();
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _auth.signUpWithEmail(email, password);
      await _syncUser();
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signOut() async {
    await _iap.logOut();
    await _auth.signOut();
    state = const UserState();
  }

  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Backend cleanup handled via API call from the screen
    await _auth.deleteAccount();
    await _iap.logOut();
    state = const UserState();
  }

  Future<void> _syncUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = const UserState();
      return;
    }

    // RevenueCat already configured in main.dart, just log in user
    await _iap.logIn(user.uid);
    await _iap.fetchOfferings();

    final premium = await _iap.isPremium();
    final adFree = await _iap.isAdFree();
    final customImage = await _iap.hasCustomImage();

    state = UserState(
      isLoading: false,
      isLoggedIn: true,
      isAnonymous: user.isAnonymous,
      displayName: user.displayName,
      email: user.email,
      uid: user.uid,
      provider: _auth.getProviderName(),
      isPremium: premium,
      isAdFree: adFree,
      hasCustomImage: customImage,
      termsAccepted: true,
    );
  }

  Future<void> refreshEntitlements() async {
    final premium = await _iap.isPremium();
    final adFree = await _iap.isAdFree();
    final customImage = await _iap.hasCustomImage();
    state = state.copyWith(
      isPremium: premium,
      isAdFree: adFree,
      hasCustomImage: customImage,
    );
  }
}
