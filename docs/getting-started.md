# Getting Started

Zero to first record in ~5 minutes.

---

## 1. Prerequisites

```bash
# Check your versions
dart --version    # need 3.8+
flutter --version # need 3.32+
docker --version  # any modern Docker

# Install Serverpod CLI if you don't have it
dart pub global activate serverpod_cli
```

Make sure `$HOME/.pub-cache/bin` is on your PATH.

---

## 2. Clone + start Postgres

```bash
git clone git@github.com:MartinPirate/spod_lite.git
cd spod_lite

docker run -d --name spod-pg \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=spodlite \
  -e POSTGRES_DB=spod_lite \
  -p 5435:5432 postgres:16-alpine
```

Postgres port `5435` is used deliberately so this repo's DB doesn't conflict with any other Postgres containers you have running.

---

## 3. Start the server

```bash
cd spod_lite/spod_lite_server

dart pub get
serverpod generate      # generates typed client + protocol files
dart bin/main.dart --apply-migrations
```

You should see:

```
SERVERPOD initialized
Latest database migration already applied.
WebServer  INFO: Webserver listening on http://localhost:8090
[dev-seed] created admin: admin@spodlite.dev / password123
```

Two things happened:

- Postgres got the tables Serverpod Lite needs (`admin_user`, `app_user`, `collection_def`, etc.).
- A dev admin was seeded — you don't have to create one.

Leave this running.

---

## 4. Build the dashboard

Open a second terminal.

```bash
cd spod_lite/spod_lite_flutter

flutter pub get
flutter build web \
  --base-href /app/ \
  --output ../spod_lite_server/web/app
```

The build drops the dashboard into the server's `web/app/` directory. The server already knows how to serve it.

---

## 5. Open it

Go to **http://localhost:8090/**.

- The landing page shows live server status, admin status, and the SDK snippet.
- Click **Open dashboard** → lands on the sign-in screen (creds pre-filled).
- Hit **Sign in**.

You're in.

---

## 6. Create your first collection

1. Click **New collection** in the left rail.
2. Name: `todo`. Label: `Todos`.
3. Add fields:
   - `title` — text — required
   - `done` — bool
   - `due_at` — datetime
4. Click **Create collection**.

Under the hood the server:
- Validated your names against the identifier safety rules.
- Inserted a `CollectionDef` row and one `CollectionField` row per field.
- Ran `CREATE TABLE collection_todo (...)` inside the same transaction.

The sidebar now shows `todo`. Click it.

---

## 7. Create your first record

- Click **New record**.
- Fill in a title, toggle `done`, pick a date.
- Create.

The row appears in the table. Click the shield icon in the header to open the **rules dialog** — flip `list` and `create` to `authed`, save.

---

## 8. Use it from Flutter

```dart
import 'package:spod_lite_sdk/spod_lite_sdk.dart';
import 'package:spod_lite_client/spod_lite_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

late final SpodLite<Client> spod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  spod = SpodLite<Client>(
    createClient: () => Client('http://localhost:8088/')
      ..connectivityMonitor = FlutterConnectivityMonitor(),
    adminEndpoint:       (c) => c.adminAuth,
    userAuthEndpoint:    (c) => c.userAuth,
    collectionsEndpoint: (c) => c.collections,
    recordsEndpoint:     (c) => c.records,
    filesEndpoint:       (c) => c.files,
  );
  await spod.userAuth.restore();
  runApp(...);
}

// Somewhere in your widget:
await spod.userAuth.signUp('me@example.com', 'password123');

final todos = await spod.collections
    .collection('todo')
    .list();

await spod.collections.collection('todo').create({
  'title': 'Ship the thing',
  'done': false,
});

// Live updates
spod.collections.collection('todo').watch().listen((change) {
  print('${change.type}: ${change.record}');
});
```

---

## 9. Run the demo app

```bash
cd demo_app
flutter pub get
flutter run -d web-server --web-port=7358
```

Open http://127.0.0.1:7358/ in two tabs. Sign up as two different users. Create a post in one tab and watch it appear live in the other.

---

## Where next

- **[Architecture](architecture.md)** — read this second, it explains why things are shaped the way they are.
- **[SDK reference](sdk.md)** — every method on `spod.*`.
- **[Rules](rules.md)** — how per-op rules work and how to set them.
- **[Realtime](realtime.md)** — `watch()` streams end to end.
- **[Files](files.md)** — uploading into `file`-type fields.
