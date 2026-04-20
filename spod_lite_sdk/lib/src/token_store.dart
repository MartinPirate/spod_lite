import 'package:serverpod_client/serverpod_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [ClientAuthKeyProvider] backed by [SharedPreferencesAsync]. Owns the
/// app-side token — kept separate from the dashboard's token so one signing
/// out doesn't affect the other.
///
/// Uses the modern Pigeon-based API to avoid the method-channel issue that
/// breaks the legacy [SharedPreferences.getInstance] on Flutter Web.
class SpodLiteTokenStore implements ClientAuthKeyProvider {
  static const _defaultKey = 'spod_lite.app.token';
  final String _prefsKey;
  final _prefs = SharedPreferencesAsync();

  SpodLiteTokenStore({String? prefsKey}) : _prefsKey = prefsKey ?? _defaultKey;

  @override
  Future<String?> get authHeaderValue async {
    final t = await get();
    return t == null ? null : 'Bearer $t';
  }

  Future<String?> get() async => _prefs.getString(_prefsKey);

  Future<void> put(String token) async => _prefs.setString(_prefsKey, token);

  Future<void> remove() async => _prefs.remove(_prefsKey);
}
