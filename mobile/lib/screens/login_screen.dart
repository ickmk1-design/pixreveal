import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/neon_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _termsAccepted = false;
  bool _showEmailForm = false;
  bool _isSignUp = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth(Future<void> Function() action) async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms & Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await action();
    final user = ref.read(userProvider);
    if (user.isLoggedIn && mounted) {
      context.go('/menu');
    } else if (user.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(user.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonPink, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPink.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'P',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 40,
                      color: AppColors.neonPink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'PIXREVEAL',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 20,
                  color: AppColors.neonPink,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(color: AppColors.neonPink, blurRadius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RETRO ARCADE PUZZLE',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 7,
                  color: AppColors.neonBlue.withValues(alpha: 0.8),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),

              if (userState.isLoading)
                const CircularProgressIndicator(color: AppColors.neonPink)
              else if (_showEmailForm)
                _buildEmailForm()
              else
                _buildAuthButtons(),

              const SizedBox(height: 24),

              // Terms checkbox
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _termsAccepted,
                      onChanged: (v) =>
                          setState(() => _termsAccepted = v ?? false),
                      activeColor: AppColors.neonPink,
                      side: const BorderSide(color: AppColors.neonBlue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _termsAccepted = !_termsAccepted),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 6,
                            color: Colors.white70,
                            height: 1.8,
                          ),
                          children: [
                            const TextSpan(text: 'I accept the '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.push('/terms'),
                                child: const Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 6,
                                    color: AppColors.neonBlue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.neonBlue,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context.push('/privacy'),
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 6,
                                    color: AppColors.neonBlue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.neonBlue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        // Apple Sign-In (iOS only)
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
          NeonButton(
            text: 'SIGN IN WITH APPLE',
            color: Colors.white,
            width: double.infinity,
            fontSize: 9,
            onPressed: () => _handleAuth(
              ref.read(userProvider.notifier).signInWithApple,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Google Sign-In
        NeonButton(
          text: 'SIGN IN WITH GOOGLE',
          color: AppColors.neonGreen,
          width: double.infinity,
          fontSize: 9,
          onPressed: () => _handleAuth(
            ref.read(userProvider.notifier).signInWithGoogle,
          ),
        ),
        const SizedBox(height: 12),

        // Email Sign-In
        NeonButton(
          text: 'SIGN IN WITH EMAIL',
          color: AppColors.neonBlue,
          width: double.infinity,
          fontSize: 9,
          onPressed: () => setState(() => _showEmailForm = true),
        ),
        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(
              child: Container(height: 1, color: Colors.white24),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 8,
                  color: Colors.white38,
                ),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: Colors.white24),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Guest mode
        NeonButton(
          text: 'PLAY AS GUEST',
          color: AppColors.neonYellow,
          width: double.infinity,
          fontSize: 9,
          onPressed: () => _handleAuth(
            ref.read(userProvider.notifier).signInAnonymously,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Guest progress can be lost.\nLink an account later in Settings.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 5,
            color: Colors.white.withValues(alpha: 0.4),
            height: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 10,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            labelText: 'EMAIL',
            labelStyle: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 8,
              color: AppColors.neonBlue.withValues(alpha: 0.7),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neonBlue),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neonPink, width: 2),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 10,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            labelText: 'PASSWORD',
            labelStyle: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 8,
              color: AppColors.neonBlue.withValues(alpha: 0.7),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neonBlue),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neonPink, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        NeonButton(
          text: _isSignUp ? 'SIGN UP' : 'SIGN IN',
          color: AppColors.neonPink,
          width: double.infinity,
          fontSize: 10,
          onPressed: () {
            final email = _emailController.text.trim();
            final password = _passwordController.text.trim();
            if (email.isEmpty || password.isEmpty) return;
            _handleAuth(() async {
              if (_isSignUp) {
                await ref
                    .read(userProvider.notifier)
                    .signUpWithEmail(email, password);
              } else {
                await ref
                    .read(userProvider.notifier)
                    .signInWithEmail(email, password);
              }
            });
          },
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(
            _isSignUp
                ? 'Already have an account? SIGN IN'
                : 'New here? SIGN UP',
            style: const TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 6,
              color: AppColors.neonBlue,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _showEmailForm = false),
          child: const Text(
            'BACK',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 8,
              color: Colors.white54,
            ),
          ),
        ),
      ],
    );
  }
}
