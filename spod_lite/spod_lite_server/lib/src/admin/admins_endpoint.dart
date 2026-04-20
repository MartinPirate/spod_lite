import 'package:bcrypt/bcrypt.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'admin_authentication_handler.dart';

/// Admin-only API for managing *other* admin users.
class AdminsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {adminScope};

  Future<List<AdminUser>> list(Session session) async {
    final admins = await AdminUser.db.find(
      session,
      orderBy: (a) => a.createdAt,
    );
    return admins.map((a) => a.copyWith(passwordHash: '')).toList();
  }

  Future<int> count(Session session) async {
    return AdminUser.db.count(session);
  }

  Future<AdminUser> invite(
    Session session,
    String email,
    String password,
  ) async {
    final normalized = email.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized)) {
      throw SpodLiteException(
        message: 'Invalid email address.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    if (password.length < 8) {
      throw SpodLiteException(
        message: 'Password must be at least 8 characters.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }

    final existing = await AdminUser.db.findFirstRow(
      session,
      where: (a) => a.email.equals(normalized),
    );
    if (existing != null) {
      throw SpodLiteException(
        message: 'An admin with that email already exists.',
        code: SpodLiteErrorCode.conflict,
      );
    }

    final hash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
    final created = await AdminUser.db.insertRow(
      session,
      AdminUser(email: normalized, passwordHash: hash),
    );
    return created.copyWith(passwordHash: '');
  }

  Future<void> revoke(Session session, int adminId) async {
    final count = await AdminUser.db.count(session);
    if (count <= 1) {
      throw SpodLiteException(
        message: 'Refusing to delete the last admin.',
        code: SpodLiteErrorCode.forbidden,
      );
    }
    await session.db.transaction((tx) async {
      await AdminSession.db.deleteWhere(
        session,
        where: (s) => s.adminUserId.equals(adminId),
        transaction: tx,
      );
      await AdminUser.db.deleteWhere(
        session,
        where: (a) => a.id.equals(adminId),
        transaction: tx,
      );
    });
  }
}
