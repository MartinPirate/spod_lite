import 'package:flutter/material.dart';
import 'package:spod_lite_sdk/spod_lite_sdk.dart';

import '../main.dart' show spod;
import '../theme.dart';

const _devEmail = 'admin@spodlite.dev';
const _devPassword = 'password123';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignedIn;
  const SignInScreen({super.key, required this.onSignedIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController(text: _devEmail);
  final _password = TextEditingController(text: _devPassword);
  bool _submitting = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await spod.auth.signInAsAdmin(_email.text.trim(), _password.text);
      widget.onSignedIn();
    } on SpodLiteAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RiseIn(child: _Brand()),
                  const SizedBox(height: 36),
                  RiseIn(
                    delay: const Duration(milliseconds: 120),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(30),
                      radius: 26,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BadgePill(),
                          const SizedBox(height: 18),
                          const Text('Welcome back',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.8,
                                  color: Glass.text)),
                          const SizedBox(height: 6),
                          const Text(
                            'Your test account is pre-filled. Tap sign in to continue.',
                            style: TextStyle(
                                color: Glass.textMuted,
                                fontSize: 14,
                                height: 1.5),
                          ),
                          const SizedBox(height: 26),
                          GlassField(
                            controller: _email,
                            label: 'EMAIL',
                            leading: Icons.alternate_email,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),
                          GlassField(
                            controller: _password,
                            label: 'PASSWORD',
                            leading: Icons.lock_outline,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.go,
                            onSubmitted: (_) => _submit(),
                            suffix: _EyeButton(
                              obscure: _obscure,
                              onTap: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            _ErrorRow(message: _error!),
                          ],
                          const SizedBox(height: 26),
                          LiquidButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.black),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text('Sign in'),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded,
                                          size: 16),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  RiseIn(
                    delay: const Duration(milliseconds: 220),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_moon_outlined,
                            size: 11, color: Glass.textFaint),
                        const SizedBox(width: 6),
                        Text('Served by Serverpod Lite · :8088',
                            style: TextStyle(
                                fontSize: 11, color: Glass.textFaint)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const LiquidMark(size: 44),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spod',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                    color: Glass.text)),
            Text('tiny client · spod_lite_sdk',
                style: TextStyle(fontSize: 11, color: Glass.textFaint)),
          ],
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Glass.hairline),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Glass.auroraA, Glass.auroraB],
                ),
              ),
            ),
            const SizedBox(width: 7),
            const Text('SIGN IN',
                style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                    color: Glass.text)),
          ],
        ),
      ),
    );
  }
}

class _EyeButton extends StatelessWidget {
  final bool obscure;
  final VoidCallback onTap;
  const _EyeButton({required this.obscure, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 16,
          color: Glass.textSubtle,
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  const _ErrorRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Glass.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Glass.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 14, color: Glass.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 12.5, color: Glass.danger, height: 1.45)),
          ),
        ],
      ),
    );
  }
}
