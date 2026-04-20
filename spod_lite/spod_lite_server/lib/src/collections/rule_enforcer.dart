import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// The three rule modes every collection op carries.
///
/// - `public` — anyone can call, no auth required.
/// - `authed` — any authenticated principal (admin OR app user).
/// - `admin`  — must hold the `admin` scope.
const ruleModes = {'public', 'authed', 'admin'};

/// Scope granted to signed-in app end-users (distinct from `admin`).
const userScope = Scope('user');

/// Throws [SpodLiteException] when the current [session] doesn't satisfy
/// [rule]. Call this at the top of every governed endpoint method.
Future<void> enforceRule(
  Session session,
  String rule, {
  required String operation,
}) async {
  if (rule == 'public') return;

  final auth = session.authenticated;
  if (auth == null) {
    throw SpodLiteException(
      message: 'Sign-in required to $operation on this collection.',
      code: SpodLiteErrorCode.unauthorized,
    );
  }

  if (rule == 'authed') return;

  if (rule == 'admin') {
    if (!auth.scopes.any((s) => s.name == 'admin')) {
      throw SpodLiteException(
        message:
            'Admin access required to $operation on this collection.',
        code: SpodLiteErrorCode.forbidden,
      );
    }
    return;
  }

  // Unknown rule string — fail closed rather than silently allowing.
  throw SpodLiteException(
    message: 'Collection rule is misconfigured: "$rule".',
    code: SpodLiteErrorCode.forbidden,
  );
}
