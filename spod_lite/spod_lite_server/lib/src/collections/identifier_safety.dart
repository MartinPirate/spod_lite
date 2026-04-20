/// SQL identifier safety for dynamic DDL/DML.
///
/// Runtime table/column names come from the dashboard (user input), so we
/// can't just interpolate them into SQL. Even quoting is not enough — a
/// malicious name with embedded quotes could still escape. So we enforce a
/// strict regex + a reserved-word blocklist, and *only then* quote.
///
/// The rule: any name that reaches [quoteIdent] has already passed
/// [isValidIdentifier]. If an attacker provides a bad name it is rejected
/// by the validator before any SQL is built.
library;

import '../generated/protocol.dart';

final RegExp _identRegExp = RegExp(r'^[a-z][a-z0-9_]{0,62}$');

/// Reserved Postgres keywords we refuse as identifiers, plus names that
/// would collide with the built-in tables Serverpod Lite manages.
const Set<String> _reserved = {
  'all', 'analyse', 'analyze', 'and', 'any', 'array', 'as', 'asc',
  'asymmetric', 'authorization', 'binary', 'both', 'case', 'cast', 'check',
  'collate', 'collation', 'column', 'concurrently', 'constraint', 'create',
  'cross', 'current_catalog', 'current_date', 'current_role',
  'current_schema', 'current_time', 'current_timestamp', 'current_user',
  'default', 'deferrable', 'desc', 'distinct', 'do', 'drop', 'else', 'end',
  'except', 'false', 'fetch', 'for', 'foreign', 'freeze', 'from', 'full',
  'grant', 'group', 'having', 'ilike', 'in', 'initially', 'inner',
  'intersect', 'into', 'is', 'isnull', 'join', 'lateral', 'leading', 'left',
  'like', 'limit', 'localtime', 'localtimestamp', 'natural', 'not',
  'notnull', 'null', 'offset', 'on', 'only', 'or', 'order', 'outer',
  'overlaps', 'placing', 'primary', 'references', 'returning', 'right',
  'select', 'session_user', 'similar', 'some', 'symmetric', 'table',
  'tablesample', 'then', 'to', 'trailing', 'true', 'union', 'unique',
  'user', 'using', 'variadic', 'verbose', 'when', 'where', 'window', 'with',
  'admin_user', 'admin_session', 'app_user', 'app_session',
  'collection_def', 'collection_field', 'post', 'greeting',
  'id', 'created_at', 'updated_at',
};

/// Returns true if [name] is safe to use as a Postgres identifier.
bool isValidIdentifier(String name) {
  if (!_identRegExp.hasMatch(name)) return false;
  if (_reserved.contains(name)) return false;
  return true;
}

/// Throws [SpodLiteException] with code `invalidInput` if [name] is not
/// safe. Use this before building any SQL that includes the name.
void assertValidIdentifier(String name, {String kind = 'identifier'}) {
  if (!isValidIdentifier(name)) {
    throw SpodLiteException(
      message: 'Invalid $kind: "$name". Must be lowercase, '
          'alphanumeric/underscore, start with a letter, 1–63 chars, '
          'and not a reserved word.',
      code: SpodLiteErrorCode.invalidInput,
    );
  }
}

/// Returns the name wrapped in double quotes so Postgres treats it as a
/// (case-sensitive) identifier. The caller *must* have already validated
/// the name via [assertValidIdentifier] — this function trusts its input.
String quoteIdent(String name) => '"$name"';

const collectionTablePrefix = 'collection_';

String tableNameFor(String collectionName) =>
    '$collectionTablePrefix$collectionName';
