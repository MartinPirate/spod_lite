import 'spod_lite_auth.dart';
import 'token_store.dart';

/// Signature for extracting the admin endpoint from your generated client.
///
/// ```dart
/// adminEndpoint: (c) => c.adminAuth
/// ```
typedef AdminAccessor<C> = dynamic Function(C client);

/// Entry point for Serverpod Lite from an application.
///
/// The SDK is generic over your generated Serverpod client type [C], so it
/// works with any Serverpod Lite backend — you bring your own
/// `package:<your_project>_client`, pass a factory, and point the SDK at
/// the admin endpoint.
///
/// ```dart
/// import 'package:spod_lite_sdk/spod_lite_sdk.dart';
/// import 'package:my_backend_client/my_backend_client.dart';
///
/// final spod = SpodLite<Client>(
///   createClient: () => Client('http://localhost:8088/'),
///   adminEndpoint: (c) => c.adminAuth,
/// );
/// await spod.auth.restore();
/// if (!spod.auth.isSignedIn) {
///   await spod.auth.signInAsAdmin('you@example.com', 'password');
/// }
/// final posts = await spod.client.posts.listPosts();  // typed!
/// ```
class SpodLite<C> {
  /// The generated Serverpod client. Use it for all your typed endpoint
  /// calls — `spod.client.posts.listPosts()`, etc.
  final C client;

  /// Auth helper. Call [SpodLiteAuth.restore] at startup to pick up any
  /// persisted session, then [SpodLiteAuth.signInAsAdmin] /
  /// [SpodLiteAuth.createFirstAdmin] / [SpodLiteAuth.signOut] as needed.
  late final SpodLiteAuth auth;

  final SpodLiteTokenStore _store;

  /// Construct a Serverpod Lite client.
  ///
  /// - [createClient] is called once during construction to build your
  ///   generated client. Configure it however you want (connectivity
  ///   monitor, SSL context, etc.); the SDK only sets `authKeyProvider`
  ///   on it afterward.
  /// - [adminEndpoint] extracts the admin endpoint from the built client;
  ///   every Serverpod Lite backend exposes it as `adminAuth`, so for most
  ///   projects this is simply `(c) => c.adminAuth`.
  /// - [tokenPrefsKey] lets you override the shared_preferences key used
  ///   for token storage — useful if you're running two Serverpod Lite
  ///   backends in the same app.
  SpodLite({
    required C Function() createClient,
    required AdminAccessor<C> adminEndpoint,
    String? tokenPrefsKey,
  })  : _store = SpodLiteTokenStore(prefsKey: tokenPrefsKey),
        client = createClient() {
    // Duck-typed because C is unconstrained — Serverpod's generated clients
    // all inherit from ServerpodClientShared which exposes authKeyProvider.
    (client as dynamic).authKeyProvider = _store;
    auth = SpodLiteAuth(adminEndpoint(client), _store);
  }

  void dispose() {
    auth.dispose();
  }
}
