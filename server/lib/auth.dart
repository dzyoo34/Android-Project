// Authentication: register/login/me, password hashing, JWT (HS256).

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';

import 'db.dart';
import 'errors.dart';

/// Secret used to sign JWTs. Override with the JWT_SECRET env variable.
final String jwtSecret =
    Platform.environment['JWT_SECRET'] ?? 'dev-secret-change-me';

// ---------------------------------------------------------------------------
// Route handlers
// ---------------------------------------------------------------------------

/// POST /auth/register  {email, password, name} -> 201 {token, user}
Future<Response> register(Request request) async {
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');

  final email = stringField(body, 'email');
  final password = stringField(body, 'password');
  final name = stringField(body, 'name');
  if (email == null || !email.contains('@')) {
    return validationError('A valid email is required');
  }
  if (password == null) return validationError('password is required');
  if (name == null) return validationError('name is required');

  final existing = db.select('SELECT id FROM users WHERE email = ?', [email]);
  if (existing.isNotEmpty) return emailTaken();

  db.execute(
    'INSERT INTO users (email, password_hash, name, created_at) '
    'VALUES (?, ?, ?, ?)',
    [email, hashPassword(password), name, nowIso()],
  );
  final id = db.lastInsertRowId;

  return jsonResponse({
    'token': issueToken(id),
    'user': {'id': id, 'email': email, 'name': name},
  }, status: 201);
}

/// POST /auth/login  {email, password} -> 200 {token, user}
Future<Response> login(Request request) async {
  final body = await readJsonBody(request);
  final email = body == null ? null : stringField(body, 'email');
  final password = body == null ? null : stringField(body, 'password');
  if (email == null || password == null) {
    return unauthorized('Invalid email or password');
  }

  final rows = db.select('SELECT * FROM users WHERE email = ?', [email]);
  if (rows.isEmpty) return unauthorized('Invalid email or password');

  final user = rows.first;
  if (!verifyPassword(password, user['password_hash'] as String)) {
    return unauthorized('Invalid email or password');
  }

  return jsonResponse({
    'token': issueToken(user['id'] as int),
    'user': {'id': user['id'], 'email': user['email'], 'name': user['name']},
  });
}

/// GET /me  (Bearer) -> 200 {id, email, name}
Future<Response> me(Request request) async {
  final rows = db.select(
    'SELECT id, email, name FROM users WHERE id = ?',
    [currentUserId(request)],
  );
  if (rows.isEmpty) return unauthorized();
  final user = rows.first;
  return jsonResponse(
    {'id': user['id'], 'email': user['email'], 'name': user['name']},
  );
}

// ---------------------------------------------------------------------------
// Auth middleware
// ---------------------------------------------------------------------------

/// Wraps a handler so it only runs with a valid `Authorization: Bearer` token.
/// Inside the handler, the logged-in user is available via [currentUserId].
Handler requireAuth(Handler inner) => (Request request) {
      final header = request.headers['authorization'] ?? '';
      if (!header.startsWith('Bearer ')) return unauthorized();
      final userId = verifyToken(header.substring('Bearer '.length));
      if (userId == null) return unauthorized();
      return inner(request.change(context: {'userId': userId}));
    };

/// The id of the logged-in user. Only valid inside a [requireAuth] handler.
int currentUserId(Request request) => request.context['userId'] as int;

// ---------------------------------------------------------------------------
// JWT (HS256), implemented by hand so you can see exactly how it works.
// A JWT is:  base64url(header) . base64url(payload) . signature
// where signature = HMAC-SHA256("header.payload", secret).
// ---------------------------------------------------------------------------

/// Creates a token for [userId], valid for 7 days. `sub` holds the user id.
String issueToken(int userId) {
  final header = _b64Json({'alg': 'HS256', 'typ': 'JWT'});
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final payload = _b64Json({
    'sub': '$userId',
    'iat': now,
    'exp': now + 7 * 24 * 60 * 60, // 7 days
  });
  return '$header.$payload.${_sign('$header.$payload')}';
}

/// Returns the user id from a valid token, or null when invalid/expired.
int? verifyToken(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  if (!_constantTimeEquals(_sign('${parts[0]}.${parts[1]}'), parts[2])) {
    return null;
  }
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now >= (payload['exp'] as int)) return null;
    return int.parse(payload['sub'] as String);
  } catch (_) {
    return null;
  }
}

String _b64Json(Map<String, Object> data) =>
    _stripPadding(base64Url.encode(utf8.encode(jsonEncode(data))));

String _sign(String data) => _stripPadding(base64Url.encode(
    Hmac(sha256, utf8.encode(jwtSecret)).convert(utf8.encode(data)).bytes));

String _stripPadding(String s) => s.replaceAll('=', '');

// ---------------------------------------------------------------------------
// Passwords: PBKDF2-HMAC-SHA256 with a random salt (no plaintext, ever).
// Stored as "iterations:salt:hash" (salt and hash base64-encoded).
// ---------------------------------------------------------------------------

const _iterations = 100000;
final _random = Random.secure();

String hashPassword(String password) {
  final salt = List<int>.generate(16, (_) => _random.nextInt(256));
  final hash = _pbkdf2(password, salt, _iterations);
  return '$_iterations:${base64.encode(salt)}:${base64.encode(hash)}';
}

bool verifyPassword(String password, String stored) {
  final parts = stored.split(':');
  if (parts.length != 3) return false;
  final iterations = int.tryParse(parts[0]);
  if (iterations == null) return false;
  final hash = _pbkdf2(password, base64.decode(parts[1]), iterations);
  return _constantTimeEquals(base64.encode(hash), parts[2]);
}

/// One 32-byte block of PBKDF2 (RFC 2898) — exactly one SHA-256 output.
List<int> _pbkdf2(String password, List<int> salt, int iterations) {
  final hmac = Hmac(sha256, utf8.encode(password));
  var block = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
  final result = List<int>.of(block);
  for (var i = 1; i < iterations; i++) {
    block = hmac.convert(block).bytes;
    for (var j = 0; j < result.length; j++) {
      result[j] ^= block[j];
    }
  }
  return result;
}

/// Compares two strings without leaking where they differ (timing attacks).
bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
