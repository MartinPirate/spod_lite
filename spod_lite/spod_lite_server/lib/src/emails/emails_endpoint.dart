import 'package:serverpod/serverpod.dart';

import '../admin/admin_authentication_handler.dart';
import '../generated/protocol.dart';
import 'email_driver.dart';

/// Admin-only API for the email module. For now: expose the active
/// driver name and a test-send. Password-reset / verification flows
/// will go on this surface later.
class EmailsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {adminScope};

  /// Returns which driver is currently active (`console` by default,
  /// `smtp` if the server was booted with SPOD_SMTP_* env vars).
  Future<String> driverName(Session session) async {
    return EmailService.instance.driver.name;
  }

  Future<void> sendTest(
    Session session,
    String to,
    String subject,
    String body,
  ) async {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(to.trim())) {
      throw SpodLiteException(
        message: 'Invalid recipient email.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    if (subject.trim().isEmpty) {
      throw SpodLiteException(
        message: 'Subject is required.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    if (body.isEmpty) {
      throw SpodLiteException(
        message: 'Body is required.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    try {
      await EmailService.instance.send(
        EmailMessage(to: to.trim(), subject: subject, body: body),
      );
    } catch (e) {
      throw SpodLiteException(
        message: 'Send failed: $e',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
  }
}
