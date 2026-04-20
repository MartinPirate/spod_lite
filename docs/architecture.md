# Architecture

Serverpod Lite is four things in one repo:

1. **A Dart server** — a regular Serverpod server, with extra endpoints, models, and middleware that implement the Lite feature set.
2. **A generated typed client** — standard Serverpod codegen output. Per-project.
3. **An SDK** — `spod_lite_sdk`, generic over any Serverpod Lite backend. Provides auth, collections, files, realtime. Publishable.
4. **Two Flutter apps** — an admin dashboard (dev-tool slate) and a demo consumer app (Apple Liquid Glass), both using the SDK.

Nothing is forked from Serverpod. Serverpod Lite is a **mode** — a set of conventions, endpoints, and helpers that compose on top of unmodified Serverpod.

---

## Data plane

```
  ┌─────────────────────────┐
  │  Static ".spy.yaml"     │   generated at build time
  │  models (AdminUser,     │   → static tables
  │  AppUser, CollectionDef,│   → typed ORM
  │  CollectionField,       │
  │  AppSession, Post…)     │
  └────────────┬────────────┘
               │
               ▼
  ┌─────────────────────────┐
  │      CollectionDef      │   rows here describe…
  │      CollectionField    │
  └────────────┬────────────┘
               │ user creates "todo"
               ▼
  ┌─────────────────────────┐
  │   collection_todo       │   …dynamic tables created at
  │   (id, created_at,      │      runtime via guarded DDL
  │   title, done, …)       │
  └─────────────────────────┘
```

Two kinds of tables live side-by-side:

- **Static tables** — defined by `.spy.yaml` and created via standard Serverpod migrations. Include built-ins (admin, app user, sessions) and the *meta* tables `collection_def` / `collection_field`.
- **Dynamic tables** — `collection_<name>`, one per user-defined collection. Created at runtime via `CREATE TABLE` when an admin submits the schema editor. Columns map from declared field types.

---

## Request paths

### Admin dashboard (solid)

```
Browser (dashboard)
  │ POST /collections/create  (Authorization: Bearer <admin-token>)
  ▼
Serverpod server
  │ authenticationHandler → chainedAuthenticationHandler
  │   • tries admin_session  → AuthenticationInfo(scope=admin) ✓
  ▼
CollectionsEndpoint.create
  │ assertValidIdentifier      (regex + reserved-word blocklist)
  │ validate field types
  │ session.db.transaction:
  │   ├─ insert CollectionDef
  │   ├─ insert each CollectionField
  │   └─ unsafeExecute('CREATE TABLE …')   (parameterized, quoted ident)
  ▼
CollectionDef row returned
```

### End-user read (public collection)

```
Browser (demo app)
  │ POST /records/list  (no auth header)
  ▼
chainedAuthenticationHandler → null (no token)
  │
  ▼
RecordsEndpoint.list
  │ load CollectionDef from DB
  │ enforceRule(session, def.listRule='public', …) ✓
  │ unsafeQuery('SELECT * FROM collection_… ORDER BY id DESC LIMIT …')
  ▼
List<String> (JSON-encoded rows)
```

### Realtime subscription

```
SDK
  │ spod.collections.collection('post').watch()
  ▼
WebSocket stream method → RecordsEndpoint.watch
  │ enforceRule(listRule)
  │ yield session.messages.createStream<RecordEvent>('records:post')
  ▼
Stream stays open; backs pressure through Serverpod's session lifecycle.

Other sessions that call records.create post RecordEvent on the same
channel via session.messages.postMessage. All active watchers receive it.
```

---

## Auth model

Two audiences, one header.

| | Admin | App user |
|---|---|---|
| Table | `admin_user` / `admin_session` | `app_user` / `app_session` |
| Sign-in endpoint | `/adminAuth/signIn` | `/userAuth/signIn`, `/userAuth/signUp` |
| Scope on resolve | `admin` | `user` |
| Who uses it | Dashboard | Demo app, any client apps |

Both tokens ride in the same `Authorization: Bearer` header. `chainedAuthenticationHandler` tries the admin session table first; if the token isn't admin, it falls through to the app-user handler. Rule evaluation then checks scopes:

| Rule | Matches |
|---|---|
| `public` | anyone (skips auth entirely) |
| `authed` | any resolved `AuthenticationInfo` (admin or user) |
| `admin` | must contain `Scope('admin')` |

Source of truth: `spod_lite_server/lib/src/collections/rule_enforcer.dart`.

---

## SQL safety

Dynamic DDL and DML use user-supplied identifiers. The invariant is:

```
 user input
    │
    ▼
assertValidIdentifier(name)   ──  regex ^[a-z][a-z0-9_]{0,62}$
    │                          └─ reserved-word blocklist
    ▼
quoteIdent(name) → "name"
    │
    ▼
only then does it reach SQL
```

Data values always go through positional / named parameters. The code never interpolates untrusted values into a query string.

Tested against sample attacks: `foo;drop table admin_user;--`, reserved words (`select`, `table`, `user`, …), uppercase names — all rejected. `admin_user` table intact after.

Source of truth: `spod_lite_server/lib/src/collections/identifier_safety.dart`.

---

## Streaming

Serverpod exposes `session.messages` as a `MessageCentral` — a typed broadcaster over named channels, with Redis support for cross-node mode.

Serverpod Lite uses two channels today:

- `records:<name>` — carries `RecordEvent` for user-defined collections.
- `posts:feed` — carries `Post` for the legacy demo endpoint.

A WebSocket stream method on the server subscribes to the channel; the Serverpod client handles the WebSocket transport. The SDK wraps the typed stream with a DTO (`RecordChange`) so apps don't import generated protocol types.

---

## File storage

Uploads go through Serverpod's `CloudStorage` abstraction. Serverpod Lite registers `DatabaseCloudStorage('public')` — files stored as rows in `serverpod_cloud_storage`. Public URLs are served by Serverpod's built-in `/serverpod_cloud_storage/file` route.

`FilesEndpoint.upload` path structure:

```
collections/<collection-name>/<record-id>/<field-name>/<sanitized-filename>
```

Filenames are sanitized: path separators stripped, special characters replaced with `_`, capped at 128 chars, empty → `upload.bin`. The resulting URL is written into the record's `file`-type column.

Future: swap `DatabaseCloudStorage` for S3 via `CloudStorage` subclass without touching `FilesEndpoint`.

---

## Why this shape

A few deliberate choices worth flagging:

**Collections are persisted as rows, not generated code.**
The typed-codegen path (Serverpod's default) breaks down when schema comes from a non-developer at runtime. Dashboard admins shouldn't have to run `serverpod generate` and commit files. Dynamic collections accept that cost and use raw SQL for their CRUD.

**Records on the wire are JSON strings, not `Map<String, dynamic>`.**
Serverpod's type system rejects `dynamic`. JSON strings sidestep the constraint and let the SDK hide the encoding at the boundary.

**Rules are three modes, not a DSL.**
`public | authed | admin` covers the 80% case. An expression DSL (`@record.owner_id = @request.auth.id`) is a future phase once there are enough use cases to design against.

**Single-file-shape identifier safety.**
Every dynamic identifier crosses one function (`assertValidIdentifier` → `quoteIdent`). Auditors only have to read one file to verify the DDL safety story.

**Admin and app user tokens share one header.**
Fewer moving parts for callers. The handler chain decides which audience owns a given token.
