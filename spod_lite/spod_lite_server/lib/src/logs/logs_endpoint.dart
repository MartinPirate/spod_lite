import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import '../admin/admin_authentication_handler.dart';

/// Admin-only read of Serverpod's recent session log table. Each row
/// is returned as a JSON string so the client can render arbitrary
/// columns without us inventing a transport type.
class LogsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {adminScope};

  Future<List<String>> recent(Session session, int limit) async {
    final capped = limit.clamp(1, 500);
    final result = await session.db.unsafeQuery(
      'select "id", "serverId", "time", "endpoint", "method", '
      '"duration", "numQueries", "slow", "error", "authenticatedUserId" '
      'from "serverpod_session_log" '
      'order by "id" desc limit @limit',
      parameters: QueryParameters.named({'limit': capped}),
    );
    return result.map((row) {
      final m = row.toColumnMap();
      return jsonEncode(m.map((k, v) {
        if (v is DateTime) return MapEntry(k, v.toUtc().toIso8601String());
        return MapEntry(k, v);
      }));
    }).toList();
  }

  Future<int> count(Session session) async {
    final result = await session.db.unsafeQuery(
      'select count(*) from "serverpod_session_log"',
    );
    return (result.first[0] as int?) ?? 0;
  }
}
