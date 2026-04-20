import 'package:serverpod/serverpod.dart';

/// The three rule modes every collection op carries.
///
/// - `public` — anyone can call, no auth required.
/// - `authed` — any authenticated principal (admin OR app user).
/// - `admin`  — must hold the `admin` scope.
const ruleModes = {'public', 'authed', 'admin'};

/// Scope granted to signed-in app end-users (distinct from `admin`).
const userScope = Scope('user');

/// Throws [RuleDeniedException] when the current [session] doesn't satisfy
/// [rule]. Call this at the top of every governed endpoint method.
Future<void> enforceRule(
  Session session,
  String rule, {
  required String operation,
}) async {
  if (rule == 'public') return;

  final auth = await session.authenticated;
  if (auth == null) {
    throw RuleDeniedException(
      'Sign-in required to $operation on this collection.',
    );
  }

  if (rule == 'authed') return;

  if (rule == 'admin') {
    if (!auth.scopes.any((s) => s.name == 'admin')) {
      throw RuleDeniedException(
        'Admin access required to $operation on this collection.',
      );
    }
    return;
  }

  // Unknown rule string — fail closed rather than silently allowing.
  throw RuleDeniedException(
    'Collection rule is misconfigured: "$rule".',
  );
}

class RuleDeniedException implements Exception {
  final String message;
  RuleDeniedException(this.message);
  @override
  String toString() => message;
}
