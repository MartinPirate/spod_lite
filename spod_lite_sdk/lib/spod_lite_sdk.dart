/// Client SDK for Serverpod Lite.
///
/// The SDK is generic — bring your own generated Serverpod client and the
/// SDK layers auth, token storage, dynamic-collections, and end-user
/// auth on top.
///
/// See [SpodLite] for usage.
library;

export 'src/spod_lite.dart';
export 'src/spod_lite_auth.dart'
    show SpodLiteAuth, AuthEvent, SpodLiteAuthException;
export 'src/spod_lite_user_auth.dart'
    show SpodLiteUserAuth, UserAuthEvent, SpodLiteUserAuthException;
export 'src/spod_lite_collections.dart';
export 'src/admin_identity.dart';
export 'src/user_identity.dart';
export 'src/token_store.dart';
