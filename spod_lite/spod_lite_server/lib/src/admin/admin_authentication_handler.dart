import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Scope granted to anyone signed in through the admin dashboard.
const adminScope = Scope('admin');

/// Resolves an incoming auth key against the `admin_session` table.
/// Returns null for unknown or expired tokens so Serverpod rejects the call.
Future<AuthenticationInfo?> adminAuthenticationHandler(
  Session session,
  String token,
) async {
  if (token.isEmpty) return null;

  final adminSession = await AdminSession.db.findFirstRow(
    session,
    where: (s) => s.token.equals(token),
  );
  if (adminSession == null) return null;

  if (adminSession.expiresAt.isBefore(DateTime.now().toUtc())) {
    await AdminSession.db
        .deleteWhere(session, where: (s) => s.token.equals(token));
    return null;
  }

  return AuthenticationInfo(
    adminSession.adminUserId.toString(),
    {adminScope},
    authId: adminSession.id!.toString(),
  );
}
