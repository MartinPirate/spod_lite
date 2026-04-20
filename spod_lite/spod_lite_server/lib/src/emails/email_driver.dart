import 'dart:io';

/// A single email payload. Kept intentionally small — attachments,
/// templating, and rich headers are future work.
class EmailMessage {
  final String to;
  final String subject;
  final String body;
  final bool html;

  const EmailMessage({
    required this.to,
    required this.subject,
    required this.body,
    this.html = false,
  });
}

/// Pluggable transport for sending an [EmailMessage]. Concrete
/// implementations: [ConsoleEmailDriver], [SmtpEmailDriver].
///
/// Drivers are held by [EmailService.instance.driver] so any callsite
/// in the app goes through the singleton without having to know the
/// transport.
abstract class EmailDriver {
  String get name;
  Future<void> send(EmailMessage message);
}

/// Logs every email to stdout. Default driver in development — lets you
/// trigger password-reset / verification flows without real SMTP.
class ConsoleEmailDriver implements EmailDriver {
  @override
  String get name => 'console';

  @override
  Future<void> send(EmailMessage message) async {
    stdout.writeln('─' * 60);
    stdout.writeln('[email:console] to:      ${message.to}');
    stdout.writeln('[email:console] subject: ${message.subject}');
    stdout.writeln('[email:console] body:');
    for (final line in message.body.split('\n')) {
      stdout.writeln('  $line');
    }
    stdout.writeln('─' * 60);
  }
}

/// Singleton wrapper around whichever [EmailDriver] is active. Call
/// `EmailService.instance.use(SmtpEmailDriver(...))` once during server
/// boot to swap in real SMTP.
class EmailService {
  EmailService._();
  static final EmailService instance = EmailService._();

  EmailDriver _driver = ConsoleEmailDriver();
  EmailDriver get driver => _driver;

  /// Replace the active driver. Safe to call at boot; call sites of
  /// [send] pick up the new driver on their next invocation.
  void use(EmailDriver driver) {
    _driver = driver;
  }

  Future<void> send(EmailMessage message) => _driver.send(message);
}
