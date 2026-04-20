import 'package:flutter/material.dart';

import '../../glass.dart';
import '../../main.dart' show client;

class EmailsScreen extends StatefulWidget {
  const EmailsScreen({super.key});

  @override
  State<EmailsScreen> createState() => _EmailsScreenState();
}

class _EmailsScreenState extends State<EmailsScreen> {
  final _to = TextEditingController();
  final _subject =
      TextEditingController(text: 'Hello from Serverpod Lite');
  final _body = TextEditingController(
      text: 'If you\'re reading this, the email module works.');
  late Future<String> _driverName;
  bool _sending = false;
  String? _ok;
  String? _error;

  @override
  void initState() {
    super.initState();
    _driverName = client.emails.driverName();
  }

  @override
  void dispose() {
    _to.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _ok = null;
      _error = null;
    });
    try {
      await client.emails
          .sendTest(_to.text.trim(), _subject.text, _body.text);
      if (!mounted) return;
      setState(() => _ok = 'Sent via the active driver.');
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString();
      try {
        final m = (e as dynamic).message;
        if (m is String && m.isNotEmpty) msg = m;
      } catch (_) {}
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: ListView(
        children: [
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.mail_outline_rounded,
                    size: 18, color: Glass.accent),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emails',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Glass.text)),
                    SizedBox(height: 2),
                    Text(
                        'Pluggable email driver. Console by default; SMTP via env vars.',
                        style: TextStyle(
                            fontSize: 12, color: Glass.textMuted)),
                  ],
                ),
                const Spacer(),
                FutureBuilder<String>(
                  future: _driverName,
                  builder: (_, snap) {
                    final label =
                        snap.connectionState != ConnectionState.done
                            ? '...'
                            : (snap.data ?? '?');
                    final isSmtp = label == 'smtp';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isSmtp ? Glass.success : Glass.auroraA)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: (isSmtp ? Glass.success : Glass.auroraA)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'driver · $label',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isSmtp ? Glass.success : Glass.auroraA,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassPanel(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Send a test email',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Glass.text)),
                const SizedBox(height: 4),
                const Text(
                  'Hits the active driver directly. The console driver prints to the server log; the SMTP driver delivers for real.',
                  style: TextStyle(
                      fontSize: 12, color: Glass.textMuted, height: 1.5),
                ),
                const SizedBox(height: 18),
                GlassField(
                  controller: _to,
                  label: 'TO',
                  hint: 'recipient@example.com',
                  leading: Icons.alternate_email,
                ),
                const SizedBox(height: 12),
                GlassField(
                  controller: _subject,
                  label: 'SUBJECT',
                  leading: Icons.short_text,
                ),
                const SizedBox(height: 12),
                GlassField(
                  controller: _body,
                  label: 'BODY',
                  leading: Icons.subject,
                ),
                if (_ok != null) ...[
                  const SizedBox(height: 14),
                  _Banner(
                    message: _ok!,
                    color: Glass.success,
                    icon: Icons.check_circle_outline,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _Banner(
                    message: _error!,
                    color: Glass.danger,
                    icon: Icons.error_outline,
                  ),
                ],
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 160,
                    child: LiquidButton(
                      onPressed: _sending ? null : _send,
                      child: _sending
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.black),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, size: 12),
                                SizedBox(width: 6),
                                Text('Send test email'),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassPanel(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Configuring SMTP',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Glass.text)),
                SizedBox(height: 6),
                Text(
                  'Set SPOD_SMTP_HOST / USER / PASS (plus optional PORT / SSL / FROM) '
                  'in the server process environment. The SMTP driver is picked up '
                  'automatically on boot; no code changes.',
                  style: TextStyle(
                      fontSize: 12.5, color: Glass.textMuted, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  const _Banner({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 12.5, color: color)),
          ),
        ],
      ),
    );
  }
}
