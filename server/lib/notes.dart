// Notes: the example CRUD entity, scoped per user.
//
// THIS FILE IS THE TEMPLATE FOR YOUR OWN ENTITIES.
// To add e.g. "recipes": copy this file to recipes.dart, rename the table
// and the fields, add a CREATE TABLE in db.dart, register routes in
// bin/server.dart. That's the whole recipe.

import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

Map<String, Object?> _toJson(Row row) => {
      'id': row['id'],
      'title': row['title'],
      'content': row['content'],
      'createdAt': row['created_at'],
    };

/// Finds a note by id, but only among the current user's notes.
/// Someone else's note is indistinguishable from a missing one (404).
Row? _find(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select(
    'SELECT * FROM notes WHERE id = ? AND user_id = ?',
    [id, userId],
  );
  return rows.isEmpty ? null : rows.first;
}

/// GET /notes?page=1&limit=20&search=  -> {items, page, limit, total}
Future<Response> listNotes(Request request) async {
  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100);
  final search = query['search'] ?? '';

  const where = 'user_id = ? AND (title LIKE ? OR content LIKE ?)';
  // %/_ in the search term act as LIKE wildcards (parameterized, so safe —
  // purely a semantic quirk).
  final args = [currentUserId(request), '%$search%', '%$search%'];

  final total =
      db.select('SELECT COUNT(*) AS n FROM notes WHERE $where', args)
          .first['n'] as int;
  final rows = db.select(
    'SELECT * FROM notes WHERE $where ORDER BY id DESC LIMIT ? OFFSET ?',
    [...args, limit, (page - 1) * limit],
  );

  return jsonResponse({
    'items': rows.map(_toJson).toList(),
    'page': page,
    'limit': limit,
    'total': total,
  });
}

/// POST /notes  {title, content} -> 201 note
Future<Response> createNote(Request request) async {
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final title = stringField(body, 'title');
  if (title == null) return validationError('title is required');
  final content = body['content'] is String ? body['content'] as String : '';

  db.execute(
    'INSERT INTO notes (user_id, title, content, created_at) '
    'VALUES (?, ?, ?, ?)',
    [currentUserId(request), title, content, nowIso()],
  );
  final row = _find(currentUserId(request), '${db.lastInsertRowId}')!;
  return jsonResponse(_toJson(row), status: 201);
}

/// GET /notes/{id} -> 200 note | 404
Future<Response> getNote(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Note not found');
  return jsonResponse(_toJson(row));
}

/// PUT /notes/{id}  {title, content} -> 200 updated note | 404
Future<Response> updateNote(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Note not found');

  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final title = stringField(body, 'title');
  if (title == null) return validationError('title is required');
  final content = body['content'] is String ? body['content'] as String : '';

  db.execute(
    'UPDATE notes SET title = ?, content = ? WHERE id = ?',
    [title, content, row['id']],
  );
  final updated = _find(currentUserId(request), '${row['id']}')!;
  return jsonResponse(_toJson(updated));
}

/// DELETE /notes/{id} -> 204 | 404
Future<Response> deleteNote(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Note not found');
  db.execute('DELETE FROM notes WHERE id = ?', [row['id']]);
  return Response(204);
}
