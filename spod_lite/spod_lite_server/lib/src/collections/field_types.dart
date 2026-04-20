/// Supported user-field types. Keep this list short and additive —
/// every type here must map to a Postgres column type and a serializable
/// Dart value.
const Set<String> knownFieldTypes = {
  'text',
  'longtext',
  'number',
  'bool',
  'datetime',
  'json',
  'file',
};

bool isKnownFieldType(String t) => knownFieldTypes.contains(t);

String sqlTypeFor(String t) {
  switch (t) {
    case 'text':
      return 'text';
    case 'longtext':
      return 'text';
    case 'number':
      return 'double precision';
    case 'bool':
      return 'boolean';
    case 'datetime':
      return 'timestamp with time zone';
    case 'json':
      return 'jsonb';
    case 'file':
      // Stores the public URL returned by the cloud storage after upload.
      return 'text';
    default:
      throw ArgumentError('Unknown field type: $t');
  }
}
