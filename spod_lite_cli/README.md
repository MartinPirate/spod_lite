# spod — Serverpod Lite CLI

A tiny CLI that scaffolds and runs Serverpod Lite projects.

## Install

```bash
dart pub global activate --source git \
  https://github.com/MartinPirate/spod_lite.git \
  --git-path spod_lite_cli
```

Make sure `$HOME/.pub-cache/bin` is on your `PATH`.

## Usage

```bash
# 1. Scaffold a new project
spod create my_app

# 2. Boot it (Postgres + server + admin dashboard)
cd my_app
spod up
```

That's it. Open `http://localhost:8090/` and sign in with the dev admin
(`admin@spodlite.dev` / `password123` — seeded automatically in dev mode).

## Commands

- **`spod create <name>`** — clones the Serverpod Lite template and renames
  everything so `<name>_server`, `<name>_client`, `<name>_flutter` live in a
  fresh project directory. Runs `pub get` unless `--no-pub-get` is passed.
- **`spod up`** — from inside a scaffolded project, brings up a Docker
  Postgres container (`postgres:16-alpine` on host port 5435) and starts the
  server with `--apply-migrations`. Pass `--skip-db` if you're managing
  Postgres yourself. Stops cleanly on `Ctrl-C`.
- **`spod version`** — prints the CLI version.

## What you get out of the box

After `spod create`, your project has:

- A Serverpod backend with chained admin + end-user authentication
- Dynamic collections (schema editor in the dashboard — no YAML required)
- Per-op rules engine (`public` / `authed` / `admin`)
- Realtime record streams over WebSocket
- File uploads backed by `DatabaseCloudStorage`
- Admin dashboard (Flutter Web) with Admins, Users, Logs, Emails, and
  Collections pages
- Dev-seeded `tasks` collection with 5 sample rows so the dashboard isn't empty
- Pluggable `EmailDriver` — `ConsoleEmailDriver` by default; swap to SMTP
  by setting `SPOD_SMTP_HOST` / `USER` / `PASS` env vars

## Requirements

- Dart SDK 3.8+
- Flutter 3.32+
- `git` on `PATH`
- Docker (only if you use `spod up` without `--skip-db`)
