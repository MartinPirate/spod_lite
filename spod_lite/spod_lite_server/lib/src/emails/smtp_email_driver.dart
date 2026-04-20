import 'dart:io';

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as smtp;

import 'email_driver.dart';

/// Real SMTP transport. Reads host/port/user/pass/from from environment
/// variables so credentials never live in the repo:
///
///   SPOD_SMTP_HOST
///   SPOD_SMTP_PORT         (default: 587)
///   SPOD_SMTP_USER
///   SPOD_SMTP_PASS
///   SPOD_SMTP_FROM         (default: SPOD_SMTP_USER)
///   SPOD_SMTP_SSL          (default: false — use STARTTLS)
///
/// Throws [StateError] at construction if SPOD_SMTP_HOST/USER/PASS are
/// missing — fail fast rather than swallow auth errors at send time.
class SmtpEmailDriver implements EmailDriver {
  final smtp.SmtpServer _server;
  final String _from;

  SmtpEmailDriver._(this._server, this._from);

  factory SmtpEmailDriver.fromEnv() {
    final host = Platform.environment['SPOD_SMTP_HOST'];
    final user = Platform.environment['SPOD_SMTP_USER'];
    final pass = Platform.environment['SPOD_SMTP_PASS'];
    if (host == null || host.isEmpty) {
      throw StateError('SPOD_SMTP_HOST is required for SmtpEmailDriver.');
    }
    if (user == null || user.isEmpty) {
      throw StateError('SPOD_SMTP_USER is required for SmtpEmailDriver.');
    }
    if (pass == null || pass.isEmpty) {
      throw StateError('SPOD_SMTP_PASS is required for SmtpEmailDriver.');
    }
    final port =
        int.tryParse(Platform.environment['SPOD_SMTP_PORT'] ?? '') ?? 587;
    final ssl =
        (Platform.environment['SPOD_SMTP_SSL'] ?? '').toLowerCase() == 'true';
    final from = Platform.environment['SPOD_SMTP_FROM'] ?? user;

    return SmtpEmailDriver._(
      smtp.SmtpServer(
        host,
        port: port,
        ssl: ssl,
        username: user,
        password: pass,
      ),
      from,
    );
  }

  @override
  String get name => 'smtp';

  @override
  Future<void> send(EmailMessage message) async {
    final m = mailer.Message()
      ..from = mailer.Address(_from, 'Serverpod Lite')
      ..recipients.add(message.to)
      ..subject = message.subject;
    if (message.html) {
      m.html = message.body;
    } else {
      m.text = message.body;
    }
    try {
      await mailer.send(m, _server);
    } on mailer.MailerException catch (e) {
      throw StateError('SMTP send failed: ${e.message}');
    }
  }
}
