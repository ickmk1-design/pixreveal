import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Anonymous sign-in
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // Google sign-in
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // If anonymous, link instead of sign in
    if (_auth.currentUser?.isAnonymous == true) {
      return await _auth.currentUser!.linkWithCredential(credential);
    }
    return await _auth.signInWithCredential(credential);
  }

  // Apple sign-in
  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    if (_auth.currentUser?.isAnonymous == true) {
      return await _auth.currentUser!.linkWithCredential(oauthCredential);
    }
    return await _auth.signInWithCredential(oauthCredential);
  }

  // Email/password sign-up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    if (_auth.currentUser?.isAnonymous == true) {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      return await _auth.currentUser!.linkWithCredential(credential);
    }
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Email/password sign-in
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Delete account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  // Get auth provider name
  String getProviderName() {
    final user = _auth.currentUser;
    if (user == null) return 'None';
    if (user.isAnonymous) return 'Guest';
    for (final info in user.providerData) {
      switch (info.providerId) {
        case 'google.com':
          return 'Google';
        case 'apple.com':
          return 'Apple';
        case 'password':
          return 'Email';
      }
    }
    return 'Unknown';
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
