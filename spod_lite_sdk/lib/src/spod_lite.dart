import 'package:serverpod_client/serverpod_client.dart';

import 'spod_lite_auth.dart';
import 'spod_lite_collections.dart';
import 'spod_lite_user_auth.dart';
import 'token_store.dart';

/// Signature for extracting an endpoint from your generated client.
///
/// ```dart
/// adminEndpoint: (c) => c.adminAuth
/// ```
typedef EndpointAccessor<C> = dynamic Function(C client);

/// Default prefs-key suffixes used to keep admin and user tokens separate.
const _adminPrefsKey = 'spod_lite.admin_token';
const _userPrefsKey = 'spod_lite.user_token';

/// Entry point for Serverpod Lite from an application.
///
/// The SDK is generic over your generated Serverpod client type [C], so
/// any Serverpod Lite backend works. You provide accessors for the four
/// endpoints every Serverpod Lite backend exposes.
///
/// ```dart
/// final spod = SpodLite<Client>(
///   createClient: () => Client('http://localhost:8088/'),
///   adminEndpoint:       (c) => c.adminAuth,
///   userAuthEndpoint:    (c) => c.userAuth,
///   collectionsEndpoint: (c) => c.collections,
///   recordsEndpoint:     (c) => c.records,
/// );
///
/// // End-user flow (for apps):
/// await spod.userAuth.signUp('jane@x.com', 'a-good-password');
/// final posts = await spod.collections.collection('post').list();
///
/// // Admin flow (for dashboards):
/// await spod.auth.signInAsAdmin('you@example.com', 'password');
/// ```
class SpodLite<C> {
  /// The generated Serverpod client. Use it directly for any typed
  /// endpoint call not covered by the SDK helpers.
  final C client;

  /// Admin auth helper — first-run bootstrap, dashboard sign-in.
  late final SpodLiteAuth auth;

  /// End-user auth helper — sign-up, sign-in for app users.
  late final SpodLiteUserAuth userAuth;

  /// Dynamic-collections API — create collections, CRUD records, manage rules.
  late final SpodLiteCollections collections;

  final SpodLiteTokenStore _adminStore;
  final SpodLiteTokenStore _userStore;
  final _ChainedKeyProvider _chained;

  SpodLite({
    required C Function() createClient,
    required EndpointAccessor<C> adminEndpoint,
    required EndpointAccessor<C> userAuthEndpoint,
    required EndpointAccessor<C> collectionsEndpoint,
    required EndpointAccessor<C> recordsEndpoint,
    required EndpointAccessor<C> filesEndpoint,
    String adminTokenPrefsKey = _adminPrefsKey,
    String userTokenPrefsKey = _userPrefsKey,
  })  : _adminStore = SpodLiteTokenStore(prefsKey: adminTokenPrefsKey),
        _userStore = SpodLiteTokenStore(prefsKey: userTokenPrefsKey),
        _chained = _ChainedKeyProvider(),
        client = createClient() {
    _chained.admin = _adminStore;
    _chained.user = _userStore;
    (client as dynamic).authKeyProvider = _chained;

    auth = SpodLiteAuth(adminEndpoint(client), _adminStore);
    userAuth = SpodLiteUserAuth(userAuthEndpoint(client), _userStore);
    collections = SpodLiteCollections(
      collectionsEndpoint(client),
      recordsEndpoint(client),
      filesEndpoint(client),
    );
  }

  void dispose() {
    auth.dispose();
    userAuth.dispose();
  }
}

/// Attaches whichever token is currently set — admin takes precedence so
/// signed-in admins always operate with admin scope when both are present
/// in the same app (rare but well-defined).
class _ChainedKeyProvider implements ClientAuthKeyProvider {
  SpodLiteTokenStore? admin;
  SpodLiteTokenStore? user;

  @override
  Future<String?> get authHeaderValue async {
    final a = await admin?.authHeaderValue;
    if (a != null) return a;
    return await user?.authHeaderValue;
  }
}
