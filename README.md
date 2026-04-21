# Serverpod Lite

**PocketBase-grade developer experience on top of Serverpod.** One Dart server, a typed client, an admin dashboard, an SDK, and a CLI — in one repo.

Sign up, define a collection visually, write a record from a Flutter app, watch it appear live in the dashboard. No YAML for collections. No Postgres `CREATE TABLE`. No hand-wiring auth.

---

## Quick start

### 1. Install the CLI

```bash
dart pub global activate --source git \
  https://github.com/MartinPirate/spod_lite.git \
  --git-path spod_lite_cli
```

Make sure `$HOME/.pub-cache/bin` is on your `PATH`.

### 2. Create and run a project

```bash
spod create my_app
cd my_app
spod up
```

`spod up` boots Postgres in Docker, applies migrations, and starts the Serverpod API + landing + dashboard. Open **http://localhost:8090/** and sign in with the dev admin — `admin@spodlite.dev` / `password123` (seeded automatically in dev mode).

### 3. Add a collection

From the dashboard (*New collection* → schema editor) **or** from the CLI:

```bash
spod add collection blog \
  --field title:text:required \
  --field body:longtext \
  --field pinned:bool

# restart the server to pick up the new migration:
spod up
```

### 4. Deploy

```bash
spod deploy                     # builds dashboard + AOT-compiles server → dist/my_app
```

Copy `dist/my_app` plus `web/`, `config/`, and `migrations/` to your host, point `SERVERPOD_*` env vars at your production Postgres, and run `./my_app --apply-migrations`.

---

## CLI commands

| | |
|---|---|
| `spod create <name>` | Scaffold a new project (server + typed client + dashboard) |
| `spod up` | Boot Postgres + the server for local dev |
| `spod add collection <name>` | Scaffold a static spy.yaml + endpoint + migration |
| `spod generate` | Wrap `serverpod generate` with auto-locate |
| `spod deploy` | Build dashboard + AOT-compile server to single binary |
| `spod version` | |

See [`spod_lite_cli/README.md`](spod_lite_cli/README.md) for flags and details.

---

## Surfaces (running locally)

| | URL | What |
|---|---|---|
| Landing | `http://localhost:8090/` | Clean slate, docs/dashboard links, live status |
| Dashboard | `http://localhost:8090/app/` | Admin console — collections, records, users, logs, emails |
| Docs | `http://localhost:8090/docs` | All guides rendered in-server with syntax highlighting |
| API | `http://localhost:8088/` | JSON over HTTP + WebSocket streams |
| Demo app | `http://127.0.0.1:7358/` | Reference Flutter app (runs with `cd demo_app && flutter run -d web-server --web-port=7358`) |

---

## What's in the box

**Foundation**
- Typed Serverpod client with generated Dart models
- Admin dashboard (Flutter Web, clean slate)
- Chained authentication — admin tokens + end-user app_user tokens from one `Authorization` header
- `spod_lite_sdk` — generic over any Serverpod Lite backend; publishable
- `spod_lite_cli` — `spod` binary for create / up / add / generate / deploy
- Tailwind landing page + in-server docs at `/docs`

**Dynamic collections**
- Schema stored in DB (`collection_def`, `collection_field`), not spy.yaml files
- Visual schema editor in the dashboard
- Generic records endpoint: `list / get / create / update / delete`
- SQL identifier safety: strict regex + reserved-word blocklist + `quoteIdent`; all DDL atomic inside transactions
- Field types: `text · longtext · number · bool · datetime · json · file`

**Rules engine**
- Per-op rules on every collection: `list / view / create / update / delete`
- Three modes: `public · authed · admin`
- Dashboard editor with per-op badges on the collection header

**End-user auth**
- Separate `AppUser` / `AppSession` tables (distinct from admins)
- Self-serve sign-up, bcrypt + sliding-window rate limit
- SDK: `spod.userAuth.signUp / signIn / signOut`

**Realtime**
- `RecordEvent` streamed via Serverpod's `MessageCentral`
- Generic `watch(collection)`, rule-gated
- Typed `CollectionRef.watch()` in the SDK returning `Stream<RecordChange>`

**File uploads**
- `file` field type on any collection
- `FilesEndpoint.upload / delete` backed by `DatabaseCloudStorage('public')`
- Dashboard file picker with image thumbnails in the record browser
- 10 MB cap in dev, filename sanitized server-side

**Serializable errors**
- `SpodLiteException { message, code }` returned as HTTP 400 with JSON body
- Stable code taxonomy: `invalidInput · unauthorized · forbidden · notFound · conflict · rateLimited`
- SDK surfaces messages on `SpodLiteAuthException` / `SpodLiteUserAuthException`

**System modules (dashboard pages)**
- **Admins** — list/invite/revoke dashboard operators
- **Users** — list/revoke-sessions/delete end-user accounts
- **Logs** — live tail of Serverpod's session log
- **Emails** — pluggable driver (`console` default, `smtp` via env vars), test-email form

**Dev-mode seeding**
- Admin account auto-created on first boot
- `tasks` collection with 5 sample rows and `authed` rules — dashboard is never empty

---

## Architecture

See **[docs/architecture.md](docs/architecture.md)** for the full picture. Ten-second version:

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
        │       HTTPS + WS        │
        └──────────────┬──────────┘
                       ▼
        ┌──────────────────────────────┐
        │      Serverpod server        │
        │  endpoints · chained auth    │
        │  rule enforcer · DDL safety  │
        │  MessageCentral · CloudStg   │
        │  email module · dev seed     │
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

## Documentation (served at `/docs` on a running server, or browse here)

- **[Getting Started](docs/getting-started.md)** — zero to first record in 5 minutes
- **[Architecture](docs/architecture.md)** — how the pieces fit
- **[SDK reference](docs/sdk.md)** — `spod.auth`, `spod.userAuth`, `spod.collections`
- **[Rules](docs/rules.md)** — per-op rules, enforcement, evaluator
- **[Realtime](docs/realtime.md)** — `watch()` streams over WebSocket
- **[Files](docs/files.md)** — upload, storage, serving
- **[Proposal (RFC)](docs/proposal.md)** — the pitch for Serverpod upstream

---

## Repo layout

```
.
├── spod_lite/                  # Serverpod workspace (the project template)
│   ├── spod_lite_server/       # Dart server — endpoints, auth, landing, docs route
│   ├── spod_lite_client/       # Generated typed client (per-backend)
│   └── spod_lite_flutter/      # Flutter Web admin dashboard
├── spod_lite_sdk/              # Generic client SDK — publishable
├── spod_lite_cli/              # The `spod` CLI — activated with dart pub global
├── demo_app/                   # Reference Flutter app using the SDK
└── docs/                       # Source markdown rendered at /docs
```

---

## Roadmap

Shipped in M1 + M2: admin dashboard, dynamic collections, rules, end-user auth, realtime, files, emails, CLI, docs.

Shipped in M3:
- Record-level rules — expression DSL over `@request` and `@record`
- Email verification + password reset (console driver in dev, SMTP in prod)
- Multi-instance realtime via Redis (`global: true` on every event)
- `spod` CLI gains `add endpoint`, `add admin`, `logs`, `deploy`, `generate`
- OAuth sign-in — Google today; provider interface for GitHub / Apple

Next:
- Dashboard UI for OAuth provider config
- `spod add oauth <provider>` scaffold
- Audit logging for rule denials

---

## Status

Prototype. Works end to end, not yet hardened for production. No test coverage yet. See [docs/proposal.md](docs/proposal.md) for the full honest scope and the upstream-merge plan.

## License

TBD.
