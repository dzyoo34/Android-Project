
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:shelf_router/shelf_router.dart';
import 'auth.dart';
import 'db.dart';
import 'errors.dart';

Map<String, Object?> _toJson(Row row) => {
  'id': row['id'],
  'name': row['name'],
  'contactPerson': row['contact_person'],
  'phone': row['phone'],
  'stage': row['stage'],
  'lastVisit': row['last_visit'],
  'createdAt': row['created_at'],
};


Row? _find(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select(
    'SELECT * FROM clients WHERE id = ? AND user_id = ?',
    [id, userId],
  );
  return rows.isEmpty ? null : rows.first;
}

String _text(Map<String, dynamic> body, String key, String fallback) {
  final value = body[key];
  return value is String ? value.trim() : fallback;
}

Future<Response> listClients(Request request) async {
  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100);
  final search = query['search'] ?? '';

  const where = 'user_id = ? AND (name LIKE ? OR contact_person LIKE ?)';
  final args = [currentUserId(request), '%$search%', '%$search%'];

  final total =
  db.select('SELECT COUNT(*) AS n FROM clients WHERE $where', args)
      .first['n'] as int;
  final rows = db.select(
    'SELECT * FROM clients WHERE $where ORDER BY id DESC LIMIT ? OFFSET ?',
    [...args, limit, (page - 1) * limit],
  );

  return jsonResponse({
    'items': rows.map(_toJson).toList(),
    'page': page,
    'limit': limit,
    'total': total,
  });
}

Future<Response> createClient(Request request) async {
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final name = stringField(body, 'name');
  if (name == null) return validationError('name is required');

  db.execute(
    'INSERT INTO clients '
        '(user_id, name, contact_person, phone, stage, last_visit, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
    [
      currentUserId(request),
      name,
      _text(body, 'contactPerson', ''),
      _text(body, 'phone', ''),
      _text(body, 'stage', 'Новый лид'),
      _text(body, 'lastVisit', ''),
      nowIso(),
    ],
  );
  final row = _find(currentUserId(request), '${db.lastInsertRowId}')!;
  return jsonResponse(_toJson(row), status: 201);
}

/// GET /clients/{id} -> 200 client | 404
Future<Response> getClient(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Client not found');
  return jsonResponse(_toJson(row));
}

/// PUT /clients/{id} -> 200 updated client | 404
Future<Response> updateClient(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Client not found');

  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final name = stringField(body, 'name');
  if (name == null) return validationError('name is required');

  db.execute(
    'UPDATE clients SET name = ?, contact_person = ?, phone = ?, '
        'stage = ?, last_visit = ? WHERE id = ?',
    [
      name,
      _text(body, 'contactPerson', row['contact_person'] as String),
      _text(body, 'phone', row['phone'] as String),
      _text(body, 'stage', row['stage'] as String),
      _text(body, 'lastVisit', row['last_visit'] as String),
      row['id'],
    ],
  );
  final updated = _find(currentUserId(request), '${row['id']}')!;
  return jsonResponse(_toJson(updated));
}

/// DELETE /clients/{id} -> 204 | 404
Future<Response> deleteClient(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Client not found');
  db.execute('DELETE FROM clients WHERE id = ?', [row['id']]);
  return Response(204);
}