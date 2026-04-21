import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

const Duration appSessionTtl = Duration(days: 30);

/// Create a fresh `AppSession` for [userId] and return its opaque token.
/// Used by email-password sign-in, sign-up, and OAuth completion —
/// keep them in one place so a TTL change reaches every sign-in path.
Future<String> mintAppSession(Session session, int userId) async {
  final token = _randomToken();
  await AppSession.db.insertRow(
    session,
    AppSession(
      token: token,
      appUserId: userId,
      expiresAt: DateTime.now().toUtc().add(appSessionTtl),
    ),
  );
  return token;
}

String _randomToken() {
  final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}
