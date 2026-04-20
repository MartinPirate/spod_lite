import 'dart:collection';

import '../generated/protocol.dart';

/// In-memory sliding-window rate limiter for admin sign-in attempts.
///
/// Serverpod Lite runs on a single node by design, so process-local state
/// is sufficient. If we ever scale horizontally, this moves to Redis or a
/// shared DB table.
class SignInRateLimiter {
  static const _windowSeconds = 15 * 60;
  static const _maxFailures = 5;
  static const _maxTrackedEmails = 10000;

  static final LinkedHashMap<String, List<DateTime>> _failures =
      LinkedHashMap<String, List<DateTime>>();

  /// Throws a [SpodLiteException] with code `rateLimited` if [email] has
  /// hit the failure cap within the rolling window.
  static void check(String email) {
    final now = DateTime.now().toUtc();
    final cutoff = now.subtract(const Duration(seconds: _windowSeconds));
    final hits = _failures[email];
    if (hits == null) return;
    hits.removeWhere((t) => t.isBefore(cutoff));
    if (hits.isEmpty) {
      _failures.remove(email);
      return;
    }
    if (hits.length >= _maxFailures) {
      final retryAt = hits.first.add(const Duration(seconds: _windowSeconds));
      final secs = retryAt.difference(now).inSeconds;
      final mins = (secs / 60).ceil();
      throw SpodLiteException(
        message:
            'Too many sign-in attempts. Try again in $mins minute${mins == 1 ? "" : "s"}.',
        code: SpodLiteErrorCode.rateLimited,
      );
    }
  }

  static void recordFailure(String email) {
    final now = DateTime.now().toUtc();
    final list = _failures.putIfAbsent(email, () => []);
    list.add(now);
    if (_failures.length > _maxTrackedEmails) {
      _failures.remove(_failures.keys.first);
    }
  }

  static void recordSuccess(String email) => _failures.remove(email);
}
