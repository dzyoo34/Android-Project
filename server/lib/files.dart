// File upload/download. Bytes live in uploads/, metadata in the database.

import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

/// Upload size cap: 5 MB — plenty for lab photos. Documented in
/// ../openapi.yaml at POST /files. Over the cap -> 400 VALIDATION_ERROR
/// (the contract deliberately has no 413).
const int maxUploadBytes = 5 * 1024 * 1024;

Response _tooLarge() =>
    validationError('File too large: the upload limit is 5 MB '
        '($maxUploadBytes bytes)');

late final Directory uploadsDir;

/// Creates the uploads/ folder on first start.
void initFileStorage(String path) {
  uploadsDir = Directory(path)..createSync(recursive: true);
}

/// POST /files  (multipart, field "file") -> 201 {id, url, name, size, mimeType}
Future<Response> uploadFile(Request request) async {
  // Cheap early rejection when the client declares the size upfront.
  // Not sufficient on its own: Content-Length can be absent (chunked
  // encoding) or lie, so the bytes are counted again while reading.
  final declared = request.contentLength;
  if (declared != null && declared > maxUploadBytes) return _tooLarge();

  final form = request.formData();
  if (form == null) {
    return validationError('Expected a multipart/form-data body');
  }

  // A corrupt multipart body (bad boundary, truncated part, ...) makes the
  // parser throw mid-stream. Without the try/catch the exception escapes the
  // handler and the connection never completes — a hung client and an easy
  // DoS. Any parse error must answer 400 instead.
  try {
    await for (final field in form.formData) {
      if (field.name != 'file') continue;

      // Read chunk by chunk, aborting as soon as the cap is exceeded.
      final buffer = BytesBuilder(copy: false);
      await for (final chunk in field.part) {
        buffer.add(chunk);
        if (buffer.length > maxUploadBytes) return _tooLarge();
      }
      final bytes = buffer.takeBytes();
      final name = field.filename ?? 'file';
      final mimeType =
          field.part.headers['content-type'] ?? 'application/octet-stream';

      // Store under a unique name: no collisions, no path tricks.
      final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final storedFile = File(
          '${uploadsDir.path}/${DateTime.now().microsecondsSinceEpoch}_$safeName');
      await storedFile.writeAsBytes(bytes);

      db.execute(
        'INSERT INTO files (user_id, name, mime_type, size, path, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [currentUserId(request), name, mimeType, bytes.length, storedFile.path,
            nowIso()],
      );
      final id = db.lastInsertRowId;

      return jsonResponse({
        'id': id,
        'url': '/files/$id',
        'name': name,
        'size': bytes.length,
        'mimeType': mimeType,
      }, status: 201);
    }
  } on Exception {
    return validationError('Malformed multipart/form-data body');
  }

  return validationError("Missing multipart field 'file'");
}

/// GET /files/{id} -> the stored bytes with their original Content-Type | 404
/// Public on purpose: lets a Flutter app show images by plain URL.
Future<Response> downloadFile(Request request) async {
  final id = int.tryParse(request.params['id'] ?? '');
  if (id == null) return notFound('File not found');

  final rows = db.select('SELECT * FROM files WHERE id = ?', [id]);
  if (rows.isEmpty) return notFound('File not found');

  final row = rows.first;
  final file = File(row['path'] as String);
  if (!file.existsSync()) return notFound('File not found');

  return Response.ok(file.openRead(), headers: {
    'content-type': row['mime_type'] as String,
    'content-length': '${row['size']}',
    // The stored Content-Type is client-supplied; nosniff stops browsers
    // from second-guessing it into something executable.
    'x-content-type-options': 'nosniff',
    // Anyone can upload text/html or image/svg+xml, so a direct visit to
    // this URL would run their scripts on our origin (stored XSS).
    // attachment = browsers download instead of rendering; the CSP sandbox
    // neutralizes anything that still renders. <img> tags and Flutter's
    // Image.network ignore both, so images keep working.
    'content-disposition': 'attachment',
    'content-security-policy': "default-src 'none'; sandbox",
  });
}
