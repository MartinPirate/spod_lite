# Rules

Every collection carries five rules, one per operation:

| Op | When it's checked |
|---|---|
| `list` | `records.list`, `records.count`, `records.watch` |
| `view` | `records.get(id)` |
| `create` | `records.create`, `files.upload` |
| `update` | `records.update` |
| `delete` | `records.delete`, `files.delete` |

A rule is either a **simple mode** or a **free-form expression**.

---

## Simple modes

The three shortcut values that cover 80% of real apps:

| Value | Meaning |
|---|---|
| `public` | Anyone — no auth required |
| `authed` | Any signed-in principal (admin OR app user) |
| `admin` | Dashboard admin only |

Defaults are `admin` for all five ops on newly-created collections. Closed by default — you opt in to looser rules explicitly.

---

## Expression rules

When simple modes aren't enough (owner-only updates, published-only reads, scope-gated writes), write a rule as an expression over the request and the record.

```
@request.auth.id = @record.owner_id
@record.published = true || @request.auth.scope = "admin"
@request.auth.id != null && @record.visibility != "private"
```

Two namespaces are available:

| Path | Meaning |
|---|---|
| `@request.auth.id` | Signed-in principal's id, or `null` |
| `@request.auth.scope` | `"admin"`, `"user"`, or `null` |
| `@record.<field>` | A column on the row being evaluated |

### Operators

| Kind | Operators |
|---|---|
| Logical | `&&`, `\|\|`, `!` |
| Equality | `=` (or `==`), `!=` |
| Ordering | `<`, `>`, `<=`, `>=` |
| Grouping | `(` … `)` |

### Literals

- Numbers: `42`, `3.14`
- Strings: `"hello"` or `'hello'`
- Booleans: `true`, `false`
- Null: `null`

No arithmetic, no function calls, no array membership. The grammar is deliberately small — it's an authorization predicate, not a scripting language.

---

## Where expression rules take effect

| Operation | How the expression is evaluated |
|---|---|
| `list` / `count` | Fetched rows are filtered in-memory through the rule. |
| `view` | The row is fetched, then evaluated. A disallowed row looks like "not found". |
| `create` | Evaluated against the proposed payload *before* the insert. |
| `update` / `delete` | Evaluated against the **current** row. |
| `watch` | `created`/`updated` events filtered by the new row state. `deleted` events carry only an id and are delivered unconditionally so live-sync UIs can remove stale items. |

Rule expressions that reference only `@request` (never `@record`) are fully resolved at the collection-level gate — no per-row scan, same performance as simple modes.

### Performance notes for row-level rules

Row-level `list` / `count` scans the collection's newest 1000 rows, filters in-app, and paginates in memory. If your collection is larger than that and uses a row-level `list` rule, page 2+ can skip data. Two options:

1. Keep the row-level rule but split the collection (hot vs. archive).
2. Replace the generic endpoint with a custom Serverpod endpoint that pushes the filter into SQL.

The cap exists to keep a malicious or accidental `list` call from scanning a million-row table; it's not a correctness guarantee at scale.

---

## Setting rules from the dashboard

On any collection's header, click the **shield icon** (or the per-op rule badges next to it). The rules dialog shows all five ops with a three-way segment control for the simple modes, plus a free-text box for expressions.

Expressions are parsed at write time — a syntax error is returned to the dialog with position information before anything hits `collection_def`.

---

## Setting rules from code

```dart
await spod.collections.updateRules('post',
  list:   'public',
  view:   '@record.published = true || @request.auth.id = @record.author_id',
  create: 'authed',
  update: '@request.auth.id = @record.author_id',
  delete: '@request.auth.id = @record.author_id || @request.auth.scope = "admin"',
);
```

You only pass the rules you're changing. Server rejects invalid values (unknown simple mode, malformed expression) with `invalidInput`.

---

## How enforcement works

Every records endpoint calls `enforceRule(session, rule, operation: ...)` as its first line after identifier validation. For simple modes and `@request`-only expressions, that's the full check. For rules that touch `@record`, `enforceRule` passes — the endpoint then calls `recordAllowed(...)` with the fetched row (or the proposed payload on create).

Design choices:

- **Fail closed.** Simple modes reject on unknown scope; expressions reject on null from a missing path.
- **Two paths, one enforcer.** `rule_enforcer.dart` is the only file that decides yes/no. Auditors read that one file to verify the rules story.
- **Not-found vs. forbidden.** Row-level denials surface as "not found" on `view` / `update` / `delete` so you can't probe existence through the rule.
- **Parse cache.** Expressions are parsed once per process (bounded to 256 distinct rules). Rules change via dashboard writes; cache is reset when the process restarts.

---

## Rules and files

Upload respects `create` (uploading is a write). Delete respects `delete`. File *reads* go through Serverpod's public storage endpoint and are as public as the URL is guessable — if you put sensitive data in a `file` field, keep the URL in a column gated by a row-level `view` rule.

---

## What rules still don't do

- **No SQL translation.** Row-level rules evaluate in Dart after the fetch. High-cardinality collections should use custom endpoints.
- **No rule-level auditing.** Failed authorizations aren't persisted. Wrap `enforceRule` if you need that.
- **No rule time-bounding / rate shaping.** Rules are either on or off for a given (principal, row) pair.

On the roadmap; push hard on any of them if you hit a use case.
