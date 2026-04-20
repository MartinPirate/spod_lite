import 'dart:collection';

/// Sliding-window rate limiter for end-user sign-in attempts.
/// Shape-identical to the admin limiter but scoped separately so an
/// attacker brute-forcing one audience doesn't lock out the other.
class UserSignInRateLimiter {
  static const _windowSeconds = 15 * 60;
  static const _maxFailures = 5;
  static const _maxTrackedEmails = 10000;

  static final LinkedHashMap<String, List<DateTime>> _failures =
      LinkedHashMap<String, List<DateTime>>();

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
      throw UserTooManyAttemptsException(
          'Too many sign-in attempts. Try again in $mins minute${mins == 1 ? "" : "s"}.');
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

class UserTooManyAttemptsException implements Exception {
  final String message;
  UserTooManyAttemptsException(this.message);
  @override
  String toString() => message;
}
