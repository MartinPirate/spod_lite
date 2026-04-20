# Rules

Every collection carries five rules, one per operation:

| Op | When it's checked |
|---|---|
| `list` | `records.list`, `records.count`, `records.watch` |
| `view` | `records.get(id)` |
| `create` | `records.create`, `files.upload` |
| `update` | `records.update` |
| `delete` | `records.delete`, `files.delete` |

Each rule takes one of three values:

| Value | Meaning |
|---|---|
| `public` | Anyone — no auth required |
| `authed` | Any signed-in principal (admin OR app user) |
| `admin` | Dashboard admin only |

Defaults are `admin` for all five ops on newly-created collections. Closed by default — you opt in to looser rules explicitly.

---

## Setting rules from the dashboard

On any collection's header, click the **shield icon** (or the per-op rule badges next to it). The rules dialog shows all five ops with a three-way segment control.

Changes are stored atomically: the row in `collection_def` gets updated in one write. Clients that already hold the old rules don't need to re-fetch — the *next* record call always sees the current rules.

---

## Setting rules from code

```dart
await spod.collections.updateRules('todo',
  list:   'public',
  create: 'authed',
  update: 'authed',
  delete: 'admin',
  // view, omitted → unchanged
);
```

You only have to pass the rules you're changing. Server ignores unknown keys and rejects invalid values.

---

## How enforcement works

Every records endpoint calls `enforceRule(session, rule, operation: ...)` as its first line after identifier validation.

```dart
Future<void> enforceRule(Session session, String rule, {required String operation}) async {
  if (rule == 'public') return;

  final auth = await session.authenticated;
  if (auth == null) {
    throw RuleDeniedException('Sign-in required to $operation on this collection.');
  }
  if (rule == 'authed') return;

  if (rule == 'admin') {
    if (!auth.scopes.any((s) => s.name == 'admin')) {
      throw RuleDeniedException('Admin access required to $operation on this collection.');
    }
    return;
  }

  throw RuleDeniedException('Collection rule is misconfigured: "$rule".');
}
```

A few design choices worth flagging:

- **Fail closed.** An unknown rule string throws rather than falling through to allow.
- **The enforcer is a single function.** Auditors read one file (`rule_enforcer.dart`) to verify the rules story. Adding a new mode means touching that one function.
- **The scope resolution already handles both audiences.** An app user has scope `user`; an admin has `admin`. `authed` accepts either; `admin` accepts only the stronger one.
- **No short-circuit inside transactions.** The rule check is outside any `db.transaction` so throwing aborts the request cleanly without rolling back state that was never written.

---

## Rules and realtime

`watch()` respects the `list` rule. Sensibly:

- A `public` collection's stream is open to anyone. No sign-in required to subscribe.
- A `authed` collection's stream requires either token.
- An `admin` collection's stream requires admin scope; regular users cannot subscribe.

The check happens once at subscribe time. A stream that was opened while you were signed in stays open even if you sign out afterwards — the Serverpod WebSocket isn't auto-revoked (revocation is in scope for a later phase).

---

## Rules and files

Upload respects `create` (uploading is a write). Delete respects `delete`. Reading a file respects nothing — files are served through Serverpod's public storage endpoint and are as public as the URL is guessable. If you put sensitive data in a `file` field, set the URL-containing field to a non-guessable path and gate `view` on the record.

---

## What rules don't do (yet)

- **No record-level rules.** You can't yet express "only the owner can update their own row". The hook is in place (per-op scoping) but the expression DSL isn't built. For now you handle ownership at the app layer, or keep sensitive data in collections locked to `admin` and project safe views through a custom endpoint.
- **No rule-level auditing.** Failed authorizations aren't persisted. If you need that, wrap `enforceRule` in a logger.
- **No rule time-bounding.** Rules are either on or off; they don't change based on request time, rate, or request count.

All three are on the M3 list.
