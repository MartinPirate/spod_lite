import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../rules/evaluator.dart';
import '../rules/expression.dart';

/// The three simple rule modes. Expressions (anything that doesn't match
/// these three) get parsed and evaluated.
const ruleModes = {'public', 'authed', 'admin'};

/// Scope granted to signed-in app end-users (distinct from `admin`).
const userScope = Scope('user');

/// Ensures a rule's *collection-level* gate passes. Called at the top of
/// every endpoint method before any record is touched.
///
/// - `public` / `authed` / `admin` are fast-path string matches.
/// - Expressions that touch only `@request.*` are evaluated here.
/// - Expressions that reference `@record.*` pass the gate; the endpoint
///   is then responsible for calling [recordAllowed] per row.
Future<void> enforceRule(
  Session session,
  String rule, {
  required String operation,
  String? collection,
}) async {
  final auth = session.authenticated;

  // Fast path: the three simple modes.
  if (rule == 'public') return;
  if (rule == 'authed') {
    if (auth == null) {
      auditRuleDenial(
        session,
        operation: operation,
        rule: rule,
        collection: collection,
        reason: 'sign-in required',
      );
      throw SpodLiteException(
        message: 'Sign-in required to $operation on this collection.',
        code: SpodLiteErrorCode.unauthorized,
      );
    }
    return;
  }
  if (rule == 'admin') {
    if (auth == null) {
      auditRuleDenial(
        session,
        operation: operation,
        rule: rule,
        collection: collection,
        reason: 'sign-in required',
      );
      throw SpodLiteException(
        message: 'Sign-in required to $operation on this collection.',
        code: SpodLiteErrorCode.unauthorized,
      );
    }
    if (!auth.scopes.any((s) => s.name == 'admin')) {
      auditRuleDenial(
        session,
        operation: operation,
        rule: rule,
        collection: collection,
        reason: 'admin scope required',
      );
      throw SpodLiteException(
        message: 'Admin access required to $operation on this collection.',
        code: SpodLiteErrorCode.forbidden,
      );
    }
    return;
  }

  // Expression mode. Parse once — cache is process-wide, see _parse.
  final expr = _parse(rule);

  // If the expression references a record field, it can only be decided
  // per-row. Collection-level gate passes; the endpoint is responsible
  // for calling [recordAllowed] on each record before surfacing it.
  if (referencesRecord(expr)) return;

  final ctx = EvalContext(
    request: _requestFor(auth),
    record: null,
  );
  final ok = evaluateBoolean(expr, ctx);
  if (!ok) {
    auditRuleDenial(
      session,
      operation: operation,
      rule: rule,
      collection: collection,
      reason: 'expression returned false',
    );
    throw SpodLiteException(
      message: 'Not allowed to $operation on this collection.',
      code: auth == null
          ? SpodLiteErrorCode.unauthorized
          : SpodLiteErrorCode.forbidden,
    );
  }
}

/// Emit a structured audit line for a rule denial. Callers (the
/// collection-level enforcer above, or RecordsEndpoint for row-level
/// checks) must invoke this whenever a principal is turned away —
/// otherwise the logs show a 403/404 with no context on *why*. Logged
/// at warning level so the dashboard's log viewer surfaces them by
/// default.
void auditRuleDenial(
  Session session, {
  required String operation,
  required String rule,
  String? collection,
  int? recordId,
  String reason = 'rule denied',
}) {
  final auth = session.authenticated;
  final principal = auth == null
      ? 'anonymous'
      : 'user:${auth.userIdentifier} '
          'scope:${auth.scopes.map((s) => s.name).join(",")}';
  final target = collection == null
      ? ''
      : recordId == null
          ? '"$collection" '
          : '"$collection"/$recordId ';
  session.log(
    '[rules] $operation $target'
    'principal=$principal rule="${_truncateRule(rule)}" — $reason',
    level: LogLevel.warning,
  );
}

String _truncateRule(String rule) {
  if (rule.length <= 80) return rule;
  return '${rule.substring(0, 77)}...';
}

/// Per-record check: evaluate [rule] against a concrete record. Used for
/// view / update / delete / post-filter on list.
///
/// Simple-mode rules pass row-level automatically if the collection-level
/// gate already passed, since they don't reference the row.
bool recordAllowed({
  required String rule,
  required AuthenticationInfo? auth,
  required Map<String, dynamic>? record,
}) {
  if (ruleModes.contains(rule)) {
    // Collection-level gate already decided; pass through row-level.
    return true;
  }
  final expr = _parse(rule);
  final ctx = EvalContext(
    request: _requestFor(auth),
    record: record,
  );
  return evaluateBoolean(expr, ctx);
}

/// Whether [rule] is a free-form expression (vs a simple mode). Used to
/// decide whether we need to fetch records to row-check.
bool isExpressionRule(String rule) => !ruleModes.contains(rule);

/// Whether [rule] actually needs per-record evaluation. `true` only for
/// expression rules that reference `@record.*`. Simple modes and
/// expressions that touch only `@request.*` are fully decided at the
/// collection-level gate, so endpoints can skip row filtering for them.
bool needsRowCheck(String rule) {
  if (ruleModes.contains(rule)) return false;
  final Expr expr;
  try {
    expr = _parse(rule);
  } on SpodLiteException {
    // Invalid expression — surfaced at the collection gate. Treat as
    // "no row check needed" so the collection-level error is the one
    // callers see, not a cryptic row-filter failure.
    return false;
  }
  return referencesRecord(expr);
}

/// Walks [expr] and returns `true` iff any `IdentExpr` starts with
/// `@record`. Cheap; cached AST means we don't re-walk often.
bool referencesRecord(Expr expr) {
  if (expr is IdentExpr) return expr.path.startsWith('@record');
  if (expr is UnaryExpr) return referencesRecord(expr.operand);
  if (expr is BinaryExpr) {
    return referencesRecord(expr.left) || referencesRecord(expr.right);
  }
  return false;
}

/// Validates an expression at rule-write time. Returns null on success
/// or an error message describing the syntax problem.
String? validateRule(String rule) {
  if (ruleModes.contains(rule)) return null;
  try {
    parseExpression(rule);
    return null;
  } on RuleSyntaxException catch (e) {
    return e.toString();
  }
}

// ─── helpers ────────────────────────────────────────────────────────

Map<String, dynamic> _requestFor(AuthenticationInfo? auth) {
  if (auth == null) {
    return const {
      'auth': {'id': null, 'scope': null},
    };
  }
  final scope = auth.scopes.isEmpty ? null : auth.scopes.first.name;
  return {
    'auth': {
      'id': auth.userIdentifier,
      'scope': scope,
    },
  };
}

/// Tiny process-wide cache so we don't re-parse the same expression on
/// every request. Rules don't change often; expressions are ~tens of
/// tokens; a simple map is plenty.
final Map<String, Expr> _parseCache = {};

Expr _parse(String source) {
  final cached = _parseCache[source];
  if (cached != null) return cached;
  try {
    final expr = parseExpression(source);
    if (_parseCache.length > 256) {
      // Bound cache to avoid unbounded growth from dashboard
      // experimentation. Cheap to re-parse when evicted.
      _parseCache.clear();
    }
    _parseCache[source] = expr;
    return expr;
  } on RuleSyntaxException catch (e) {
    throw SpodLiteException(
      message: 'Collection rule has a syntax error: ${e.toString()}',
      code: SpodLiteErrorCode.forbidden,
    );
  }
}
