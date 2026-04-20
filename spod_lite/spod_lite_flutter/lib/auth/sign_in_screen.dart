import 'package:flutter/material.dart';
import '../theme.dart';
import 'auth_state.dart';

class SignInScreen extends StatefulWidget {
  final AuthState state;
  final bool isBootstrap;

  const SignInScreen({
    super.key,
    required this.state,
    required this.isBootstrap,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

// Dev-mode pre-fill so you can just click the button during iteration.
const _devEmail = 'admin@spodlite.dev';
const _devPassword = 'password123';

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController(text: _devEmail);
  final _password = TextEditingController(text: _devPassword);
  final _confirm = TextEditingController(text: _devPassword);
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = widget.isBootstrap
        ? await widget.state
            .createFirstAdmin(_email.text.trim(), _password.text)
        : await widget.state.signIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isBootstrap
        ? 'Create your first admin'
        : 'Sign in to Serverpod Lite';
    final subtitle = widget.isBootstrap
        ? 'This account will have full access to the dashboard. You can add more admins later.'
        : 'Enter your admin credentials to continue.';
    final cta = widget.isBootstrap ? 'Create admin' : 'Sign in';

    return Scaffold(
      backgroundColor: Tokens.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Brand(),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Tokens.surface,
                    border: Border.all(color: Tokens.border),
                    borderRadius: BorderRadius.circular(Tokens.radiusLg),
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.isBootstrap)
                          _SetupBadge(),
                        if (widget.isBootstrap) const SizedBox(height: 16),
                        Text(title,
                            style:
                                Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Text(subtitle,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 22),
                        _Label('Email'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _email,
                          autofocus: true,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_submitting,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                              hintText: 'you@example.com'),
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty) return 'Email is required.';
                            if (!t.contains('@')) return 'Invalid email.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _Label('Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          enabled: !_submitting,
                          style: const TextStyle(fontSize: 13),
                          onFieldSubmitted:
                              widget.isBootstrap ? null : (_) => _submit(),
                          textInputAction: widget.isBootstrap
                              ? TextInputAction.next
                              : TextInputAction.go,
                          decoration: InputDecoration(
                            hintText: widget.isBootstrap
                                ? 'At least 8 characters'
                                : 'Enter password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 16),
                              color: Tokens.textMuted,
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if ((v ?? '').isEmpty) return 'Password is required.';
                            if (widget.isBootstrap && v!.length < 8) {
                              return 'Use at least 8 characters.';
                            }
                            return null;
                          },
                        ),
                        if (widget.isBootstrap) ...[
                          const SizedBox(height: 14),
                          _Label('Confirm password'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirm,
                            obscureText: _obscure,
                            enabled: !_submitting,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                                hintText: 'Re-enter password'),
                            onFieldSubmitted: (_) => _submit(),
                            validator: (v) {
                              if (v != _password.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),
                        ],
                        if (widget.state.error != null) ...[
                          const SizedBox(height: 14),
                          _ErrorBanner(message: widget.state.error!),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 40,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    width: 14, height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.black)),
                                  )
                                : Text(cta),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    widget.isBootstrap
                        ? 'After setup, this screen becomes the sign-in page.'
                        : 'Lost access? Reset the admin row directly in the database.',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
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
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Tokens.accent,
            borderRadius: BorderRadius.circular(Tokens.radiusMd),
          ),
          alignment: Alignment.center,
          child: const Text('S',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
        ),
        const SizedBox(width: 12),
        const Text('Serverpod Lite',
            style: TextStyle(
                color: Tokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3)),
      ],
    );
  }
}

class _SetupBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Tokens.accentSoft.withValues(alpha: 0.4),
          border: Border.all(color: Tokens.accent.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(Tokens.radiusSm),
        ),
        child: const Text('FIRST-RUN SETUP',
            style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: Tokens.accent)),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Tokens.textSecondary,
            letterSpacing: 0.2));
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Tokens.danger.withValues(alpha: 0.08),
        border: Border.all(color: Tokens.danger.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(Tokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 14, color: Tokens.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 12, color: Tokens.danger, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
