# SDK reference

`spod_lite_sdk` — the client package.

## Install

```yaml
# pubspec.yaml
dependencies:
  spod_lite_sdk:
    git:
      url: https://github.com/MartinPirate/spod_lite.git
      path: spod_lite_sdk

  # Your project's generated Serverpod client.
  my_backend_client:
    path: ../my_backend/my_backend_client

  # Only if you want connectivity monitoring.
  serverpod_flutter: 3.4.7
```

The SDK is generic over your generated client type. Every Serverpod Lite backend exposes the five endpoints it needs: `adminAuth`, `userAuth`, `collections`, `records`, `files`.

## Construct

```dart
import 'package:spod_lite_sdk/spod_lite_sdk.dart';
import 'package:my_backend_client/my_backend_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

late final SpodLite<Client> spod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  spod = SpodLite<Client>(
    createClient: () => Client('https://api.yourdomain.com/')
      ..connectivityMonitor = FlutterConnectivityMonitor(),
    adminEndpoint:       (c) => c.adminAuth,
    userAuthEndpoint:    (c) => c.userAuth,
    collectionsEndpoint: (c) => c.collections,
    recordsEndpoint:     (c) => c.records,
    filesEndpoint:       (c) => c.files,
  );
  runApp(...);
}
```

The SDK creates two separate token stores (admin and user) and wires them into the generated client's `authKeyProvider` with a chained provider. You don't manage tokens directly.

## `spod.auth` — admin sign-in

For dashboards, internal tools. Token persists across reloads.

```dart
await spod.auth.restore();                 // pick up saved session
await spod.auth.createFirstAdmin(email, password);  // first-run only
await spod.auth.signInAsAdmin(email, password);
spod.auth.currentUser;                     // AdminIdentity?
spod.auth.isSignedIn;                      // bool
spod.auth.events;                          // Stream<AuthEvent>
await spod.auth.signOut();
await spod.auth.invalidate();              // clear local session

bool hasAdmins = await spod.auth.hasAdmins();  // for first-run checks
```

`AdminIdentity { id, email, createdAt }`. Password hashes never reach the client.

## `spod.userAuth` — end-user sign-up / sign-in

For apps you ship to end-users. Own token store, own scope (`user`).

```dart
await spod.userAuth.restore();
await spod.userAuth.signUp('jane@example.com', 'a-good-password');
await spod.userAuth.signIn('jane@example.com', 'a-good-password');
spod.userAuth.currentUser;                 // UserIdentity?
spod.userAuth.isSignedIn;                  // bool
spod.userAuth.events;                      // Stream<UserAuthEvent>
await spod.userAuth.signOut();
await spod.userAuth.invalidate();
```

`UserIdentity { id, email, createdAt }`.

Password requirements server-side: at least 8 characters, at most 256. Rate limit: 5 failed sign-ins per email per 15 minutes.

## `spod.collections` — dynamic collections

### Manage definitions

```dart
final defs = await spod.collections.list();  // List<CollectionInfo>
final def  = await spod.collections.get('todo');
final fields = await spod.collections.fields(def.id);

await spod.collections.create(
  name: 'todo',
  label: 'Todos',
  fields: [
    FieldSpec(name: 'title', type: FieldType.text, required: true),
    FieldSpec(name: 'done',  type: FieldType.bool$),
    FieldSpec(name: 'photo', type: FieldType.file),
  ],
);

await spod.collections.delete('todo');  // drops the backing table too

await spod.collections.updateRules('todo',
  list: 'public',
  create: 'authed',
);
```

**Collection names**: lowercase, start with a letter, `[a-z0-9_]`, max 63 chars. No reserved words.

**Field types**: `text · longtext · number · bool · datetime · json · file`.

### Records — the fluent API

```dart
final todos = spod.collections.collection('todo');

await todos.list();                // List<Map<String, dynamic>>
await todos.list(page: 2, perPage: 50);
await todos.count();               // int
await todos.getOne(42);            // Map<String, dynamic>?
await todos.create({'title': 'Buy milk', 'done': false});
await todos.update(42, {'done': true});
await todos.delete(42);
```

Records are plain maps. Values match your field types (`num` for number, `bool` for bool, ISO 8601 `String` for datetime, etc.).

### Realtime

```dart
final sub = todos.watch().listen((change) {
  switch (change.type) {
    case RecordChangeType.created: /* new row */
    case RecordChangeType.updated: /* edited */
    case RecordChangeType.deleted: /* gone */
  }
  change.record;   // Map<String, dynamic>? — null for deletes
  change.recordId; // int
  change.at;       // DateTime
});

// Later:
await sub.cancel();
```

The stream respects the collection's `list` rule. Public collections stream to anyone; admin collections require a sign-in. Backed by Serverpod's `MessageCentral` over a WebSocket.

### Files

```dart
await todos.uploadFile(
  recordId: 42,
  fieldName: 'photo',
  bytes: pickedBytes,        // Uint8List
  filename: 'avatar.png',
);
// Returns the public URL that's now stored on the record.

await todos.deleteFile(
  recordId: 42,
  fieldName: 'photo',
);
```

Upload respects the `create` rule (same as record creation — uploading *is* a write). Delete respects the `delete` rule. 10 MB cap in development.

## `spod.client` — escape hatch

For anything the SDK doesn't wrap, you still have the typed Serverpod client:

```dart
await spod.client.posts.watchPosts().listen(...);  // any custom endpoint
```

The SDK sets `authKeyProvider` on the client for you, so typed calls inherit auth automatically.

## Error types

```dart
SpodLiteAuthException        // admin auth failures
SpodLiteUserAuthException    // user auth failures
ServerpodClientException     // any endpoint failure (message on the .message)
```

All three expose `.message` for display.

## Disposing

```dart
spod.dispose();  // closes auth event streams
```

Call this when tearing down the whole app. Normally not needed in Flutter because `SpodLite` is a singleton.

## Platform support

`shared_preferences` drives token storage. That runs on Flutter Web, iOS, Android, macOS, Windows, Linux. Pure Dart (non-Flutter) isn't supported yet — the token store would need a different backend.

The SDK uses `SharedPreferencesAsync` rather than the legacy `SharedPreferences.getInstance()` to avoid a `MissingPluginException` that hits legacy method channels on some Flutter Web builds.
