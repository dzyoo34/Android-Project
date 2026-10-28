// Standard responses and small JSON helpers used by every route.
//
// Every error in the API has the same shape:
//   {"error": {"code": "SOME_CODE", "message": "human readable text"}}

import 'dart:convert';

import 'package:shelf/shelf.dart';

/// Sends [data] as a JSON response.
Response jsonResponse(Object data, {int status = 200}) => Response(
      status,
      body: jsonEncode(data),
      headers: const {'content-type': 'application/json'},
    );

/// The standard error body: {"error": {"code": ..., "message": ...}}.
Response apiError(int status, String code, String message) =>
    jsonResponse({'error': {'code': code, 'message': message}}, status: status);

Response validationError(String message) =>
    apiError(400, 'VALIDATION_ERROR', message);

Response unauthorized([String message = 'Missing or invalid token']) =>
    apiError(401, 'UNAUTHORIZED', message);

Response notFound([String message = 'Resource not found']) =>
    apiError(404, 'NOT_FOUND', message);

Response emailTaken() =>
    apiError(409, 'EMAIL_TAKEN', 'An account with this email already exists');

/// Reads the request body as a JSON object, or null when it is not one.
Future<Map<String, dynamic>?> readJsonBody(Request request) async {
  try {
    final decoded = jsonDecode(await request.readAsString());
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

/// Returns body[key] as a trimmed non-empty string, or null when missing.
String? stringField(Map<String, dynamic> body, String key) {
  final value = body[key];
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
