import 'package:serverpod/serverpod.dart';
import '../collections/rule_enforcer.dart';
import '../generated/protocol.dart';

/// Resolves an incoming token against the `app_session` table.
/// Returns null if the token is unknown, expired, or empty — letting the
/// chained handler try the admin side next.
Future<AuthenticationInfo?> userAuthenticationHandler(
  Session session,
  String token,
) async {
  if (token.isEmpty) return null;

  final appSession = await AppSession.db.findFirstRow(
    session,
    where: (s) => s.token.equals(token),
  );
  if (appSession == null) return null;

  if (appSession.expiresAt.isBefore(DateTime.now().toUtc())) {
    await AppSession.db
        .deleteWhere(session, where: (s) => s.token.equals(token));
    return null;
  }

  return AuthenticationInfo(
    appSession.appUserId.toString(),
    {userScope},
    authId: appSession.id!.toString(),
  );
}
