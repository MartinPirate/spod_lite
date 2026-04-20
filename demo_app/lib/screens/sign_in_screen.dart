import 'package:flutter/material.dart';
import 'package:spod_lite_sdk/spod_lite_sdk.dart';

import '../main.dart' show spod;
import '../theme.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignedIn;
  const SignInScreen({super.key, required this.onSignedIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

enum _Mode { signIn, signUp }

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  _Mode _mode = _Mode.signUp; // default to signup for first-run magic
  bool _submitting = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _localValidate() {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'That doesn\'t look like a valid email.';
    }
    if (password.isEmpty) return 'Password is required.';
    if (_mode == _Mode.signUp && password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final localError = _localValidate();
    if (localError != null) {
      setState(() => _error = localError);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (_mode == _Mode.signUp) {
        await spod.userAuth.signUp(_email.text.trim(), _password.text);
      } else {
        await spod.userAuth.signIn(_email.text.trim(), _password.text);
      }
      widget.onSignedIn();
    } on SpodLiteUserAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      // Fallback — SpodLiteException subclasses already have .message,
      // and any remaining raw ServerpodClientException gets regex-cleaned.
      String message;
      try {
        final m = (e as dynamic).message;
        message = m is String && m.isNotEmpty ? m : e.toString();
      } catch (_) {
        final s = e.toString();
        final m =
            RegExp(r'ServerpodClientException[^:]*:\s*(.+)').firstMatch(s);
        message = (m?.group(1) ?? s).trim();
      }
      setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == _Mode.signUp;
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
                          _ModeToggle(
                            mode: _mode,
                            onChanged: (m) => setState(() {
                              _mode = m;
                              _error = null;
                            }),
                          ),
                          const SizedBox(height: 22),
                          Text(isSignUp ? 'Create your account' : 'Welcome back',
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.8,
                                  color: Glass.text)),
                          const SizedBox(height: 6),
                          Text(
                            isSignUp
                                ? 'Sign up to use the Spod Demo.'
                                : 'Sign in with the account you created.',
                            style: const TextStyle(
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
                            hint: 'you@example.com',
                          ),
                          const SizedBox(height: 14),
                          GlassField(
                            controller: _password,
                            label: 'PASSWORD',
                            leading: Icons.lock_outline,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.go,
                            onSubmitted: (_) => _submit(),
                            hint: isSignUp ? 'At least 8 characters' : null,
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
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(isSignUp ? 'Create account' : 'Sign in'),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded,
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

class _ModeToggle extends StatelessWidget {
  final _Mode mode;
  final ValueChanged<_Mode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Glass.hairline),
      ),
      child: Row(
        children: [
          Expanded(
              child: _ModeButton(
                  label: 'Sign up',
                  selected: mode == _Mode.signUp,
                  onTap: () => onChanged(_Mode.signUp))),
          Expanded(
              child: _ModeButton(
                  label: 'Sign in',
                  selected: mode == _Mode.signIn,
                  onTap: () => onChanged(_Mode.signIn))),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: selected ? null : onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Glass.auroraA, Glass.auroraB],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black : Glass.textMuted,
          ),
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
