/// Client SDK for Serverpod Lite.
///
/// The SDK is generic — bring your own generated Serverpod client and the
/// SDK layers auth, token storage, and dynamic-collection helpers on top.
///
/// See [SpodLite] for usage.
library;

export 'src/spod_lite.dart';
export 'src/spod_lite_auth.dart'
    show SpodLiteAuth, AuthEvent, SpodLiteAuthException;
export 'src/spod_lite_collections.dart';
export 'src/admin_identity.dart';
export 'src/token_store.dart';
