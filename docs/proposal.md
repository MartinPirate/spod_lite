# Proposal — Serverpod Quickstart

> *A PocketBase-grade on-ramp, built as a mode on top of Serverpod (not a fork).*

## Problem

Serverpod is the best server framework for Flutter that exists. Typed end to end, Dart-native, scales horizontally, clean ORM, streaming baked in. Developers who invest an afternoon in it come away loving it.

The investment is the problem.

Compare the zero-to-first-record path on the three backends a Flutter dev evaluates:

|                  | **Firebase** | **PocketBase** | **Serverpod** |
|------------------|--------------|----------------|-------------------|
| Define a "posts" collection | web console | web console | write `post.spy.yaml`, wire endpoint class, `serverpod generate`, `create-migration`, restart |
| See records in a browser | console | admin UI | *no dashboard exists* |
| Read from Flutter | firebase SDK | pocketbase SDK | generated client |
| Time to first record | ~5 min | ~2 min | 20–45 min |

None of these gaps are because Serverpod is technically weaker. They exist because Serverpod is developer-ergonomic at the *code* level but not at the *bootstrap* level, and because the admin UX that every modern BaaS now bundles has no Dart-ecosystem equivalent.

The result is that teams who would otherwise love Serverpod pick Supabase or PocketBase for their prototype and never come back.

## Proposal

Ship **Serverpod Quickstart** as a first-party mode on top of Serverpod. Same engine, same client, same deploy story — but with the conventions and UI that turn "Serverpod" into the default answer to "what backend should I use for my Flutter app?"

Concretely, Serverpod Quickstart ships:

1. **Dynamic collections** — an admin creates a collection in the dashboard; server generates a backing table via guarded DDL; a generic records endpoint handles CRUD. No `serverpod generate` needed to ship a new collection.
2. **A Flutter Web admin dashboard** — served by the same binary. Record browser, schema editor, rules editor, realtime indicators. PocketBase-feel for the actual work, Linear-feel for the density.
3. **Two-audience auth** — admin auth for the dashboard, self-serve app-user auth for end-user apps. Chained authentication handler so one header resolves either.
4. **A tiny rules system** — three modes per operation (`public · authed · admin`). Enough to cover the demo cases without inventing a DSL on day one.
5. **Realtime out of the box** — `MessageCentral` drives a `watch()` stream on every collection, rule-gated.
6. **File uploads** — wraps `DatabaseCloudStorage` behind a `file` field type. Dashboard file picker with thumbnails.
7. **An SDK package** — `spod_lite_sdk`, generic over any generated Serverpod client. One import on the app side; clean auth, collections, realtime, files. Publishable to pub.dev as-is.

None of this is a fork. Every feature composes on top of Serverpod primitives already in the framework (`Endpoint`, `Session`, `MessageCentral`, `CloudStorage`, streaming methods, `authenticationHandler`).

## Merge path

Three shapes of how this could land upstream, ranked by how invasive they are:

**(A) New package in the monorepo — `serverpod_quickstart`.**
All of Serverpod Lite's code lives in `packages/serverpod_quickstart/`. Existing Serverpod projects are unaffected. A new starter template `serverpod create --quickstart my_app` gives you the full stack.

**(B) A CLI command — `serverpod init-quickstart`.**
Ships the dashboard and the Lite endpoints as a scaffold inside a Serverpod project, like `flutter create` scaffolds platform directories. Zero runtime coupling between core and Lite.

**(C) Optional runtime integration — `pod.enableQuickstart()`.**
Call it once in `server.dart`; it registers the endpoints, mounts the dashboard under `/app`, wires the landing page. Good for retrofit on an existing Serverpod project.

These are not mutually exclusive — (A) and (C) could ship together, with (A) as the scaffold and (C) as the runtime switch. The prototype in this repo is the raw code (A) would package.

## What's shipped in the prototype

Everything on this list is running end-to-end against Postgres right now.

- **Backend** — 44 commits on `main`. CollectionDef + CollectionField models, generic CRUD endpoint, SQL identifier safety (regex + reserved-word blocklist), atomic DDL inside transactions, rule enforcement on every op, chained admin+user authentication handler, rate-limited sign-in for both audiences, bcrypt password hashing, `RecordEvent` streams via `MessageCentral`, `FilesEndpoint` over `DatabaseCloudStorage`.
- **SDK** — `spod_lite_sdk` package. Generic over the generated client type. `SpodLite<C>` entry point; `auth` for admins, `userAuth` for end-users, `collections` with a fluent record API (`spod.collections.collection('x').list() / .create(...) / .watch() / .uploadFile(...)`). Two separate token stores, chained bearer provider.
- **Dashboard** — Flutter Web, clean-slate design. Shell + nav rail + record browser + schema editor + rules editor + file picker + delete confirms. Rebuilds to `web/app` and ships inside the server binary under `/app`.
- **Demo app** — Flutter Web, Apple Liquid Glass design (deliberate differentiation from the dashboard). Sign-up/sign-in toggle against `userAuth`. Realtime post feed with pulse indicator.
- **Landing** — Tailwind + Inter, served at `/`. Shows live backend status.
- **Adversarial SQL tested** — `foo;drop table admin_user;--`, reserved words, uppercase — all rejected. `admin_user` intact after the run.

Repo: **github.com/MartinPirate/spod_lite**

## What it's not

Honest about the gaps — some of these are M3 candidates, some are "if the Serverpod team decides the direction is right" candidates.

- **No record-level rules.** Rules are per-op per-collection today. A PocketBase-style expression DSL (`@record.owner_id = @request.auth.id`) is the natural next step; the enforcement point is already factored so it's a single-function upgrade.
- **No test coverage.** The adversarial paths have been exercised manually; a proper integration suite is next.
- **Realtime is single-node.** `MessageCentral` broadcasts on one server. Multi-instance deployments need the Redis path already in core Serverpod — we just haven't wired that config through.
- **Files are DB-backed.** `DatabaseCloudStorage` scales to maybe low GB per tenant. S3 is a one-class swap away (`CloudStorage` is the interface).
- **No OAuth / email verification / password reset.** Password+email only. `serverpod_auth_idp` could power the OAuth path without reinventing.
- **Not production-hardened.** No observability wiring, no CSRF plan (we're bearer-only which is fine), no audit log.

## Open questions for the Serverpod team

Posted as questions because the answers depend on direction I don't have.

1. **Is dynamic-collections the right abstraction?** The alternative is staying code-first and investing in faster codegen + a lighter CLI loop. Dynamic collections force a second type of storage (meta tables + raw SQL); codegen is type-safe end to end but harder to hand to a non-developer.
2. **How much of the dashboard belongs in core?** Record browser seems universal; rules editor and file field UI are opinionated. One middle path: core ships the chrome and record browser, everything else is an opt-in package.
3. **Where does the SDK live?** Pub as `serverpod_quickstart_sdk`? In the monorepo? Re-exported from `serverpod_client` behind a flag?
4. **What's the sign-off bar before this is an official path?** Happy to do the test coverage, the RFC polish, the docs, the deployment story — just want to know what "good" looks like before sinking time.

## Why I built it

I'm prepping to apply to the Serverpod team. Building Serverpod Quickstart gave me a real reason to read `endpoint_dispatch`, `serverpod_cli/generator`, `MessageCentral`, `CloudStorage`, the session + auth model, and the codegen pipeline — not as a tutorial reader but as someone trying to extend them. The code in the repo is the artifact of that reading.

I'd rather ship this to Viktor's team than a cover letter.

— Martin Kiragu · github.com/martinkiragu
