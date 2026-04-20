import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'identifier_safety.dart';
import 'rule_enforcer.dart';

/// Upload/delete files attached to records on user-defined collections.
///
/// The public URL is written into the record's column (type 'file'), and
/// served back via Serverpod's built-in `/serverpod_cloud_storage/file`
/// endpoint. Rule enforcement mirrors record writes: `createRule` for
/// uploads, `deleteRule` for removals.
class FilesEndpoint extends Endpoint {
  /// Maximum supported upload size (kept consistent with
  /// `maxRequestSize` in development.yaml so errors surface clearly).
  static const maxUploadBytes = 10 * 1024 * 1024;

  Future<String> upload(
    Session session,
    String collectionName,
    int recordId,
    String fieldName,
    ByteData bytes,
    String filename,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    assertValidIdentifier(fieldName, kind: 'field name');

    if (bytes.lengthInBytes == 0) {
      throw _FileException('Upload is empty.');
    }
    if (bytes.lengthInBytes > maxUploadBytes) {
      throw _FileException(
          'File is larger than ${(maxUploadBytes / (1024 * 1024)).round()} MB.');
    }

    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.createRule, operation: 'upload');

    final field = await _requireField(session, def.id!, fieldName);
    if (field.fieldType != 'file') {
      throw _FileException(
          'Field "$fieldName" is type "${field.fieldType}", not "file".');
    }

    final safeName = _sanitizeFilename(filename);
    final storagePath =
        'collections/$collectionName/$recordId/$fieldName/$safeName';

    await session.storage.storeFile(
      storageId: 'public',
      path: storagePath,
      byteData: bytes,
    );

    final publicUrl = await session.storage.getPublicUrl(
      storageId: 'public',
      path: storagePath,
    );
    if (publicUrl == null) {
      throw _FileException(
          'Storage accepted the upload but returned no public URL.');
    }
    final urlString = publicUrl.toString();

    // Update the record's field with the URL.
    final table = quoteIdent(tableNameFor(collectionName));
    await session.db.unsafeExecute(
      'update $table set ${quoteIdent(fieldName)} = @url '
      'where "id" = @id',
      parameters: QueryParameters.named({
        'url': urlString,
        'id': recordId,
      }),
    );

    session.log('[files] uploaded $storagePath (${bytes.lengthInBytes} bytes)');
    return urlString;
  }

  Future<void> delete(
    Session session,
    String collectionName,
    int recordId,
    String fieldName,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    assertValidIdentifier(fieldName, kind: 'field name');

    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.deleteRule, operation: 'file-delete');

    final field = await _requireField(session, def.id!, fieldName);
    if (field.fieldType != 'file') {
      throw _FileException(
          'Field "$fieldName" is type "${field.fieldType}", not "file".');
    }

    // Best-effort: delete anything at that path prefix, clear the column.
    final prefix =
        'collections/$collectionName/$recordId/$fieldName/';
    final exists = await session.storage.fileExists(
      storageId: 'public',
      path: prefix,
    );
    if (exists) {
      await session.storage.deleteFile(storageId: 'public', path: prefix);
    }

    final table = quoteIdent(tableNameFor(collectionName));
    await session.db.unsafeExecute(
      'update $table set ${quoteIdent(fieldName)} = null '
      'where "id" = @id',
      parameters: QueryParameters.named({'id': recordId}),
    );
  }

  Future<CollectionDef> _requireCollection(
      Session session, String name) async {
    final def = await CollectionDef.db.findFirstRow(
      session,
      where: (c) => c.name.equals(name),
    );
    if (def == null) {
      throw _FileException('Collection "$name" does not exist.');
    }
    return def;
  }

  Future<CollectionField> _requireField(
      Session session, int collectionDefId, String name) async {
    final field = await CollectionField.db.findFirstRow(
      session,
      where: (f) =>
          f.collectionDefId.equals(collectionDefId) & f.name.equals(name),
    );
    if (field == null) {
      throw _FileException('Field "$name" does not exist on this collection.');
    }
    return field;
  }

  /// Strip anything funky from a filename before it becomes part of a path.
  /// Keeps letters, digits, dashes, underscores, and the extension dot.
  String _sanitizeFilename(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'upload.bin';
    final name = trimmed.split(RegExp(r'[\\/]')).last;
    final cleaned = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (cleaned.isEmpty || cleaned == '.' || cleaned == '..') {
      return 'upload.bin';
    }
    return cleaned.length > 128 ? cleaned.substring(0, 128) : cleaned;
  }
}

class _FileException implements Exception {
  final String message;
  _FileException(this.message);
  @override
  String toString() => message;
}
