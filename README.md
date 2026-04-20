# Serverpod Lite

**PocketBase-grade developer experience on top of Serverpod.** One Dart server, a typed client, an admin dashboard, an SDK, and a demo app — in one repo.

Sign up, define a collection visually, write a record from a Flutter app, watch it appear live in the dashboard. No YAML for collections. No Postgres `CREATE TABLE`. No hand-wiring auth.

---

## Surfaces

| | URL (local) | Aesthetic |
|---|---|---|
| Landing | `http://localhost:8090/` | Clean slate (dev-tool flavor) |
| Admin dashboard | `http://localhost:8090/app/` | Clean slate — Linear / PocketBase density |
| Demo app | `http://127.0.0.1:7358/` | Apple Liquid Glass — consumer app flavor |
| API | `http://localhost:8088/` | JSON over HTTP + WebSocket streams |

---

## Quick start

### Prerequisites

- Dart 3.8+ / Flutter 3.32+
- Docker (for Postgres)
- Serverpod CLI: `dart pub global activate serverpod_cli`

### Run it

```bash
# 1. Postgres
docker run -d --name spod-pg \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=spodlite \
  -e POSTGRES_DB=spod_lite \
  -p 5435:5432 postgres:16-alpine

# 2. Server (auto-seeds admin@spodlite.dev / password123 in dev)
cd spod_lite/spod_lite_server
dart pub get
serverpod generate
dart bin/main.dart --apply-migrations

# 3. Dashboard (build once, served from /app)
cd ../spod_lite_flutter
flutter build web --base-href /app/ --output ../spod_lite_server/web/app

# 4. Demo app (dev server)
cd ../../demo_app
flutter run -d web-server --web-port=7358
```

Open **http://localhost:8090/** → click *Open dashboard* → creds are pre-filled → sign in → create a collection.

---

## What's in the box

**M1 — foundation** ✅
- Typed Serverpod client with generated Dart models
- Admin dashboard (dark slate) with record browser
- Admin auth (bcrypt, rate-limited, token-gated API)
- `spod_lite_sdk` package — generic over any Serverpod Lite backend
- Tailwind landing page with live backend status
- Demo Flutter app (Apple Liquid Glass aesthetic)

**M2.1 — dynamic collections** ✅
- Schema stored in DB, not `.spy.yaml` files
- Visual schema editor in dashboard
- Generic records endpoint (`list / get / create / update / delete`)
- SQL identifier safety (strict regex, reserved-word blocklist, `quoteIdent`)
- All DDL atomic inside a transaction
- Field types: `text · longtext · number · bool · datetime · json · file`

**M2.2 — rules engine** ✅
- Per-op rules on every collection: `list / view / create / update / delete`
- Three modes: `public · authed · admin`
- Dashboard rules editor with per-op badges on the collection header

**M2.3 — end-user auth** ✅
- Separate `AppUser` / `AppSession` tables (distinct from admins)
- Self-serve sign-up with bcrypt + sliding-window rate limit
- Chained authentication handler (admin first, then app user)
- `spod.userAuth` flow in the SDK

**M2.4 — realtime** ✅
- `RecordEvent` streamed via Serverpod's `MessageCentral`
- Generic `watch(collection)` on records, rule-gated
- Typed `CollectionRef.watch()` in the SDK returning `Stream<RecordChange>`
- Live pulse indicator in the demo app when new records arrive

**M2.5 — file uploads** ✅
- `file` field type backed by `DatabaseCloudStorage('public')`
- `FilesEndpoint.upload / delete` with rule enforcement
- Dashboard file picker with image thumbnails in the record browser
- Filename sanitization, 10 MB cap in dev

**Roadmap** *(not yet shipped)*
- Record-level rules (`@record.owner_id = @request.auth.id`)
- OAuth providers on user auth
- Email verification / password reset
- Multi-instance realtime (Redis)
- Single-binary production build
- Admin management page

---

## Architecture

See **[docs/architecture.md](docs/architecture.md)** for the full picture. In one diagram:

```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Dashboard   │   │   Demo app    │   │  Your Flutter │
│  (Flutter Web)│   │  (Flutter Web)│   │      app      │
└───────┬───────┘   └───────┬───────┘   └───────┬───────┘
        │                   │ uses              │ uses
        │                   ▼                   ▼
        │          ┌─────────────────────────────┐
        │          │       spod_lite_sdk         │
        │          │  auth · collections · files │
        │          │  realtime (typed streams)   │
        │          └──────────────┬──────────────┘
        │                         │
        │      HTTPS + WS         │
        └──────────────┬──────────┘
                       ▼
        ┌──────────────────────────────┐
        │      Serverpod server        │
        │  endpoints · chained auth    │
        │  rule enforcer · DDL safety  │
        │  MessageCentral · CloudStg   │
        └──────────────┬───────────────┘
                       │
                       ▼
                ┌──────────────┐
                │   Postgres   │
                │  static +    │
                │  dynamic     │
                │  tables      │
                └──────────────┘
```

---

## Documentation

- **[Getting Started](docs/getting-started.md)** — zero to first record in 5 minutes
- **[Architecture](docs/architecture.md)** — how the pieces fit together
- **[SDK reference](docs/sdk.md)** — `spod.auth`, `spod.userAuth`, `spod.collections`
- **[Rules](docs/rules.md)** — per-op rules, enforcement, evaluator
- **[Realtime](docs/realtime.md)** — `watch()` streams over WebSocket
- **[Files](docs/files.md)** — upload, storage, serving
- **[Proposal (RFC)](docs/proposal.md)** — the pitch for Serverpod upstream

---

## Credentials (dev mode)

The dev admin is auto-seeded on first boot:
- Email: `admin@spodlite.dev`
- Password: `password123`

These only exist in development mode. Delete `dev_seed.dart` before shipping anything production-adjacent.

---

## Repo layout

```
.
├── spod_lite/                  # Serverpod workspace
│   ├── spod_lite_server/       # Dart server
│   ├── spod_lite_client/       # Generated typed client (per-backend)
│   └── spod_lite_flutter/      # Flutter Web admin dashboard
├── spod_lite_sdk/              # Generic client SDK — published as a package
├── demo_app/                   # Reference Flutter app using the SDK
└── docs/                       # This directory
```

---

## Status

Single-author prototype. Works end to end, not yet hardened for production. No test coverage. See [docs/proposal.md](docs/proposal.md) for the full honest scope.

## License

TBD.
