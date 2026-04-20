# Realtime

Every collection is live. Every write is broadcast. Every subscriber sees it immediately.

---

## The shape

```dart
final sub = spod.collections.collection('todo').watch().listen((change) {
  print('${change.type} #${change.recordId}');
});
```

`change` is a `RecordChange`:

```dart
class RecordChange {
  final RecordChangeType type;        // created | updated | deleted
  final String collectionName;
  final int recordId;
  final Map<String, dynamic>? record; // null for deletes
  final DateTime at;
}
```

---

## What triggers an event

```
client calls      │  channel              │  event emitted
──────────────────┼───────────────────────┼────────────────────
records.create    │  records:<collection> │  RecordChangeType.created
records.update    │  records:<collection> │  RecordChangeType.updated
records.delete    │  records:<collection> │  RecordChangeType.deleted
files.upload      │  records:<collection> │  RecordChangeType.updated
                  │                       │  (the record's URL column changed)
```

`files.delete` also emits `updated` since it modifies the record.

---

## Transport

Under the hood this is a Serverpod streaming method:

```dart
// in records_endpoint.dart
Stream<RecordEvent> watch(Session session, String collectionName) async* {
  assertValidIdentifier(collectionName, kind: 'collection name');
  final def = await _requireCollection(session, collectionName);
  await enforceRule(session, def.listRule, operation: 'watch');
  yield* session.messages.createStream<RecordEvent>(_eventChannel(collectionName));
}
```

The Serverpod client opens a WebSocket to the API server; the stream method yields events onto it. The SDK wraps those typed events in the `RecordChange` DTO on the consumer side.

Writes broadcast via `session.messages.postMessage(channel, event)` — that's `MessageCentral`, Serverpod's cross-isolate pub/sub. On a single-node deployment it's in-process. If you configure Redis in your Serverpod config, `MessageCentral` uses it automatically — the same code works across many server instances.

---

## Rules and realtime

`watch()` checks the `list` rule, same as `records.list`. See [rules.md](rules.md) for details.

The check runs *once* at subscribe time. A stream held open after sign-out keeps emitting until the client cancels it. Server-driven revocation (kill a stream on sign-out, or on rule change) is M3.

---

## Backpressure and errors

The stream is a regular Dart `Stream<RecordChange>`. Standard `.listen` semantics:

```dart
final sub = stream.listen(
  (change) { /* … */ },
  onError: (e) {
    // fires on transport errors (WebSocket disconnect)
  },
  onDone: () {
    // fires when the server-side stream completes (unusual — you'd
    // normally cancel locally before this happens)
  },
  cancelOnError: false,
);
```

When the WebSocket drops (e.g., server restart), the SDK doesn't auto-reconnect yet. The cleanest approach is to `listen` with `onError: (_) => _resubscribe()` and re-fetch a snapshot after reconnect, since you may have missed events during the outage.

Don't hold a reference to `change.record` maps for long. They're owned by the stream and passing them into stateless widgets is fine, but they aren't immutable — Serverpod is free to reuse the containers.

---

## Patterns

### List + watch = live list

```dart
final todos = spod.collections.collection('todo');

List<Map<String, dynamic>> items = await todos.list();

final sub = todos.watch().listen((change) {
  setState(() {
    switch (change.type) {
      case RecordChangeType.created:
        items = [change.record!, ...items];
      case RecordChangeType.updated:
        items = [
          for (final i in items)
            if (i['id'] == change.recordId) change.record! else i
        ];
      case RecordChangeType.deleted:
        items = items.where((i) => i['id'] != change.recordId).toList();
    }
  });
});
```

For small lists this is enough. For long lists consider the [windowed snapshot](#) pattern (doc TBD) where you only subscribe to events whose `recordId` falls inside the currently-viewed page.

### One-shot first-event

```dart
final first = await spod.collections.collection('todo').watch().first;
```

Blocks until someone else writes. Useful for tests or scripted waits.

### Multiple subscribers on one client

Safe. Each `.listen()` is its own subscription. All observers see every event. Cancel independently.

---

## What realtime doesn't do (yet)

- **No replay.** Clients that subscribe late don't get historical events — you'd normally combine `list()` for the initial snapshot with `watch()` for the delta.
- **No filtering.** You get all events on a collection. Per-record filtering happens in your handler.
- **No scope-aware events.** Deletes include the `recordId` but not the pre-delete record content, even if the subscriber would have been allowed to view it.
- **Single-node by default.** Configure Redis in your Serverpod config for cross-instance.
