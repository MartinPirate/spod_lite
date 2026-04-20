# Serverpod Lite

PocketBase-grade developer experience on top of Serverpod. One Dart server, a typed client, an admin dashboard, and an SDK — all in one repo.

## What's inside

```
.
├── spod_lite/              # Serverpod project (workspace)
│   ├── spod_lite_server/   # Dart server — endpoints, auth, landing
│   ├── spod_lite_client/   # Generated typed client (per-backend)
│   └── spod_lite_flutter/  # Flutter web admin dashboard
├── spod_lite_sdk/          # Generic client SDK — auth + token storage
└── demo_app/               # Tiny Flutter app that uses the SDK
```

## Prerequisites

- Dart 3.8+ and Flutter 3.32+
- Docker (for Postgres)
- Serverpod CLI: `dart pub global activate serverpod_cli`

## Run it

```bash
# 1. Postgres
docker run -d --name spod-pg \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=spodlite \
  -e POSTGRES_DB=spod_lite \
  -p 5435:5432 postgres:16-alpine

# 2. Server
cd spod_lite/spod_lite_server
dart pub get
serverpod generate
dart bin/main.dart --apply-migrations

# 3. Dashboard (in another shell) — either dev mode…
cd spod_lite/spod_lite_flutter
flutter run -d web-server --web-port=7357

# …or build into the server's /app route:
flutter build web --base-href /app/ --output ../spod_lite_server/web/app
# then open http://localhost:8090/app/

# 4. Demo app (optional)
cd demo_app
flutter run -d web-server --web-port=7358
```

Visit:
- http://localhost:8090/ — landing
- http://localhost:8090/app/ — dashboard (built) or http://localhost:7357/ (dev)
- http://localhost:7358/ — demo app
- http://localhost:8088/ — API

Dev admin is seeded automatically: `admin@spodlite.dev` / `password123`.

## Status

**M1 (shipped):** server + posts collection, admin auth (bcrypt, rate-limited, gated API), Liquid Glass dashboard, SDK package, demo app, landing page.

**M2 (next):** dynamic collections (schema-in-DB, generic CRUD, visual builder in dashboard), rules engine, end-user auth, file uploads.

## License

Provisional — TBD.
