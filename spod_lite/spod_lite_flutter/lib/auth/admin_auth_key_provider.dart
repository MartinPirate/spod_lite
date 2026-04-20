import 'package:serverpod_client/serverpod_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const adminTokenKey = 'spod_lite.admin_token';

/// Single source of truth for the admin session token.
///
/// Uses [SharedPreferencesAsync] (Pigeon-based) rather than the legacy
/// [SharedPreferences.getInstance] to avoid the method-channel issue that
/// manifests on Flutter Web builds as "No implementation found for method
/// getAll on channel plugins.flutter.io/shared_preferences".
class AdminAuthKeyProvider implements ClientAuthKeyProvider {
  final _prefs = SharedPreferencesAsync();

  @override
  Future<String?> get authHeaderValue async {
    final t = await get();
    return t == null ? null : 'Bearer $t';
  }

  Future<String?> get() async => _prefs.getString(adminTokenKey);

  Future<void> put(String token) async =>
      _prefs.setString(adminTokenKey, token);

  Future<void> remove() async => _prefs.remove(adminTokenKey);
}
