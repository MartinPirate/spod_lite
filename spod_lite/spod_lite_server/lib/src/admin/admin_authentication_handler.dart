import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../users/user_authentication_handler.dart';

/// Scope granted to anyone signed in through the admin dashboard.
const adminScope = Scope('admin');

/// Chained authentication handler. We try the admin session table first;
/// if the token isn't an admin token, we fall through to the app-user
/// handler. This lets the same header authenticate either audience
/// without the caller needing to know which.
Future<AuthenticationInfo?> chainedAuthenticationHandler(
  Session session,
  String token,
) async {
  final adminInfo = await _resolveAdmin(session, token);
  if (adminInfo != null) return adminInfo;
  return userAuthenticationHandler(session, token);
}

Future<AuthenticationInfo?> _resolveAdmin(
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

/// Backwards-compatible alias: the wiring in `server.dart` historically
/// referenced `adminAuthenticationHandler`.
Future<AuthenticationInfo?> adminAuthenticationHandler(
  Session session,
  String token,
) =>
    chainedAuthenticationHandler(session, token);
