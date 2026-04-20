import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

const devAdminEmail = 'admin@spodlite.dev';
const devAdminPassword = 'password123';

/// In development mode, insert a known admin so the sign-in form can be
/// pre-filled and first-run bootstrap is skipped. No-op in staging/prod.
Future<void> seedDevAdminIfMissing(Serverpod pod) async {
  if (pod.runMode != 'development') return;

  final session = await pod.createSession(enableLogging: false);
  try {
    final existing = await AdminUser.db.findFirstRow(
      session,
      where: (u) => u.email.equals(devAdminEmail),
    );
    if (existing != null) {
      stdout.writeln(
          '[dev-seed] admin already present: $devAdminEmail — nothing to do');
      return;
    }

    final hash =
        BCrypt.hashpw(devAdminPassword, BCrypt.gensalt(logRounds: 12));
    await AdminUser.db.insertRow(
      session,
      AdminUser(email: devAdminEmail, passwordHash: hash),
    );
    stdout.writeln(
        '[dev-seed] created admin: $devAdminEmail / $devAdminPassword');
  } finally {
    await session.close();
  }
}
