import 'expression.dart';

/// Context passed to [evaluateExpression]. Built once per request and
/// reused across row-level evaluations in a list.
class EvalContext {
  /// The current principal. `null` for unauthenticated requests.
  /// Shape: `{'auth': {'id': String?, 'scope': String?}}` — missing
  /// fields become `null`.
  final Map<String, dynamic>? request;

  /// The record being evaluated. Missing for create when no row exists
  /// yet (we build one from the submitted payload in that case).
  final Map<String, dynamic>? record;

  const EvalContext({this.request, this.record});

  /// Handy factory when a request is anonymous.
  static const EvalContext anonymous = EvalContext(
    request: {'auth': {'id': null, 'scope': null}},
  );

  /// Look up an `@` path against this context. Returns `null` for
  /// missing segments rather than throwing — rule authors can write
  /// `@request.auth.id != null` without worrying about whether `auth`
  /// exists.
  dynamic lookup(String path) {
    if (!path.startsWith('@')) return null;
    final parts = path.substring(1).split('.');
    dynamic current;
    switch (parts[0]) {
      case 'request':
        current = request;
      case 'record':
        current = record;
      default:
        return null;
    }
    for (var i = 1; i < parts.length; i++) {
      if (current is! Map) return null;
      current = current[parts[i]];
    }
    return current;
  }
}

/// Walks the AST and returns the computed value. For top-level use pass
/// the result through [_asBool] to coerce to a strict boolean.
dynamic evaluate(Expr expr, EvalContext ctx) {
  if (expr is LiteralExpr) return expr.value;
  if (expr is IdentExpr) return ctx.lookup(expr.path);
  if (expr is UnaryExpr) {
    final v = evaluate(expr.operand, ctx);
    switch (expr.op) {
      case TokenType.bang:
        return !_truthy(v);
      default:
        throw StateError('Unknown unary op ${expr.op}');
    }
  }
  if (expr is BinaryExpr) {
    switch (expr.op) {
      case TokenType.and:
        final left = evaluate(expr.left, ctx);
        if (!_truthy(left)) return false;
        return _truthy(evaluate(expr.right, ctx));
      case TokenType.or:
        final left = evaluate(expr.left, ctx);
        if (_truthy(left)) return true;
        return _truthy(evaluate(expr.right, ctx));
      case TokenType.eq:
        return _eq(evaluate(expr.left, ctx), evaluate(expr.right, ctx));
      case TokenType.neq:
        return !_eq(evaluate(expr.left, ctx), evaluate(expr.right, ctx));
      case TokenType.lt:
        return _cmp(evaluate(expr.left, ctx), evaluate(expr.right, ctx)) < 0;
      case TokenType.gt:
        return _cmp(evaluate(expr.left, ctx), evaluate(expr.right, ctx)) > 0;
      case TokenType.lte:
        return _cmp(evaluate(expr.left, ctx), evaluate(expr.right, ctx)) <= 0;
      case TokenType.gte:
        return _cmp(evaluate(expr.left, ctx), evaluate(expr.right, ctx)) >= 0;
      default:
        throw StateError('Unknown binary op ${expr.op}');
    }
  }
  return null;
}

/// Top-level: evaluates [expr] and coerces the result to `bool`.
bool evaluateBoolean(Expr expr, EvalContext ctx) =>
    _truthy(evaluate(expr, ctx));

bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.isNotEmpty;
  if (v is Iterable) return v.isNotEmpty;
  if (v is Map) return v.isNotEmpty;
  return true;
}

/// Cross-type equality: null-tolerant, number-normalising. String "1"
/// and number 1 are NOT equal — we don't coerce across types (that's a
/// footgun for rule authors).
bool _eq(dynamic a, dynamic b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return a == b;
  return a == b;
}

/// Total ordering for `<` etc. Cross-type returns 0 (treat as equal) so
/// the comparison is never a silent "yes". Rule authors should always
/// compare same-type values; otherwise the rule probably has a bug.
int _cmp(dynamic a, dynamic b) {
  if (a == null || b == null) return 0;
  if (a is num && b is num) return a.compareTo(b);
  if (a is String && b is String) return a.compareTo(b);
  if (a is DateTime && b is DateTime) return a.compareTo(b);
  return 0;
}
