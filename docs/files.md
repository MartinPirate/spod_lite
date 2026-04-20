# Files

Collections can have `file`-type fields. Upload bytes; the record's field stores the public URL.

---

## Declaring a file field

In the schema editor (or via `spod.collections.create`):

```dart
await spod.collections.create(
  name: 'profile',
  label: 'Profiles',
  fields: [
    FieldSpec(name: 'display_name', type: FieldType.text, required: true),
    FieldSpec(name: 'avatar',       type: FieldType.file),
  ],
);
```

Behind the scenes the `avatar` column is a `text` column. It holds the public URL of the uploaded file, or `null` if no file is attached.

---

## Uploading

```dart
// somewhere you have a Uint8List + filename (e.g., from file_picker)
final url = await spod.collections
    .collection('profile')
    .uploadFile(
      recordId: 42,
      fieldName: 'avatar',
      bytes: pickedBytes,
      filename: 'selfie.png',
    );
// url is https://your-server/serverpod_cloud_storage/file?path=collections%2F...
```

The call:
1. Enforces the collection's `create` rule.
2. Validates the field exists and is of type `file`.
3. Stores the bytes in `DatabaseCloudStorage('public')` under `collections/<name>/<recordId>/<fieldName>/<sanitized-filename>`.
4. Updates the record's column with the resulting public URL.
5. Returns the URL.

A `RecordChange.updated` event fires on the collection's `watch()` stream.

---

## Deleting

```dart
await spod.collections.collection('profile').deleteFile(
  recordId: 42,
  fieldName: 'avatar',
);
```

Enforces the `delete` rule. Clears the URL column and removes the stored file.

---

## Reading

Just fetch the record and read the column:

```dart
final record = await spod.collections.collection('profile').getOne(42);
final url = record?['avatar'];
if (url != null) {
  // Use it in your app — Image.network(url), anchor tag, etc.
}
```

The URL is publicly accessible from anywhere — the server's built-in `/serverpod_cloud_storage/file` route serves files without auth. If your content is sensitive, either don't use public storage, or keep the collection's `view` rule locked to `admin` (the URL itself is a capability).

---

## Limits

- Default 10 MB upload cap (set by `maxRequestSize` in `config/development.yaml`).
- 128-char cap on the sanitized filename.
- Empty uploads are rejected.

Filenames get sanitized on the server before becoming path components:
- Path separators (`/ \`) are stripped.
- Anything outside `[A-Za-z0-9._-]` becomes `_`.
- Empty / `.` / `..` becomes `upload.bin`.

---

## Storage

`DatabaseCloudStorage` is the default — files live as rows in `serverpod_cloud_storage`. Cheap to set up, terrible at scale past tens of gigabytes. Swap to S3 (or any Serverpod-compatible `CloudStorage` implementation) by replacing one line in `server.dart`:

```dart
pod.addCloudStorage(YourS3CloudStorage('public'));
```

`FilesEndpoint` uses `session.storage` which delegates to whatever storage is registered under the name `'public'` — the rest of the code doesn't care.

---

## What files don't do (yet)

- **No direct uploads.** Bytes go through the API server. For large files you'd want a signed-URL upload flow — Serverpod's `CloudStorage.createDirectFileUploadDescription` supports it; we just haven't wired a Serverpod Lite endpoint around it.
- **No progress callbacks.** Upload returns a single future; no streaming progress yet.
- **No thumbnail generation.** The dashboard previews images inline but serves the original. A separate "thumbnail" storage bucket is a clean future add.
- **No content-type enforcement.** The server accepts any bytes. Use file field validation on the client (or extend `FieldSpec` with a MIME-type constraint — future work).
- **No multiple files per field.** One file per (record, field). A list-of-files field type is future work.
