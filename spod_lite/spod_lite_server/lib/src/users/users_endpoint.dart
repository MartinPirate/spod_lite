import 'package:serverpod/serverpod.dart';

import '../admin/admin_authentication_handler.dart';
import '../generated/protocol.dart';

/// Admin-only API for managing end-user accounts.
class UsersEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {adminScope};

  Future<List<AppUser>> list(
    Session session, {
    int page = 1,
    int perPage = 50,
  }) async {
    final cappedPage = page.clamp(1, 10000);
    final cappedPer = perPage.clamp(1, 200);
    final rows = await AppUser.db.find(
      session,
      orderBy: (u) => u.createdAt,
      orderDescending: true,
      limit: cappedPer,
      offset: (cappedPage - 1) * cappedPer,
    );
    return rows.map((u) => u.copyWith(passwordHash: '')).toList();
  }

  Future<int> count(Session session) async => AppUser.db.count(session);

  Future<int> sessionCount(Session session, int userId) async {
    return AppSession.db
        .count(session, where: (s) => s.appUserId.equals(userId));
  }

  Future<void> revokeSessions(Session session, int userId) async {
    await AppSession.db.deleteWhere(
      session,
      where: (s) => s.appUserId.equals(userId),
    );
  }

  Future<void> delete(Session session, int userId) async {
    await session.db.transaction((tx) async {
      await AppSession.db.deleteWhere(
        session,
        where: (s) => s.appUserId.equals(userId),
        transaction: tx,
      );
      await AppUser.db.deleteWhere(
        session,
        where: (u) => u.id.equals(userId),
        transaction: tx,
      );
    });
  }
}
