import 'spod_lite_auth.dart';
import 'spod_lite_collections.dart';
import 'token_store.dart';

/// Signature for extracting an endpoint from your generated client.
///
/// ```dart
/// adminEndpoint: (c) => c.adminAuth
/// ```
typedef EndpointAccessor<C> = dynamic Function(C client);

/// Entry point for Serverpod Lite from an application.
///
/// The SDK is generic over your generated Serverpod client type [C], so it
/// works with any Serverpod Lite backend — you bring your own
/// `package:<your_project>_client`, pass a factory, and point the SDK at
/// the three endpoints every Serverpod Lite backend exposes:
/// `adminAuth`, `collections`, and `records`.
///
/// ```dart
/// import 'package:spod_lite_sdk/spod_lite_sdk.dart';
/// import 'package:my_backend_client/my_backend_client.dart';
///
/// final spod = SpodLite<Client>(
///   createClient: () => Client('http://localhost:8088/'),
///   adminEndpoint: (c) => c.adminAuth,
///   collectionsEndpoint: (c) => c.collections,
///   recordsEndpoint: (c) => c.records,
/// );
///
/// await spod.auth.restore();
/// await spod.auth.signInAsAdmin('you@example.com', 'password');
///
/// final todos = await spod.collections
///     .collection('todo')
///     .list();
/// ```
class SpodLite<C> {
  /// The generated Serverpod client. Use it directly for any typed endpoint
  /// call not covered by the SDK helpers.
  final C client;

  /// Auth helper — admin sign-in, sign-out, first-run bootstrap.
  late final SpodLiteAuth auth;

  /// Dynamic-collections API — create collections, CRUD records.
  late final SpodLiteCollections collections;

  final SpodLiteTokenStore _store;

  SpodLite({
    required C Function() createClient,
    required EndpointAccessor<C> adminEndpoint,
    required EndpointAccessor<C> collectionsEndpoint,
    required EndpointAccessor<C> recordsEndpoint,
    String? tokenPrefsKey,
  })  : _store = SpodLiteTokenStore(prefsKey: tokenPrefsKey),
        client = createClient() {
    // Duck-typed: Serverpod's generated clients all inherit from
    // ServerpodClientShared which exposes authKeyProvider.
    (client as dynamic).authKeyProvider = _store;

    auth = SpodLiteAuth(adminEndpoint(client), _store);
    collections = SpodLiteCollections(
      collectionsEndpoint(client),
      recordsEndpoint(client),
    );
  }

  void dispose() {
    auth.dispose();
  }
}
