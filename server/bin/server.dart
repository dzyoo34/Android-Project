// PAM backend template - Dart/Shelf reference implementation.
//
// Start:  dart pub get && dart run
// Env:    PORT (default 8080), JWT_SECRET (default dev-secret-change-me)

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:server/auth.dart';
import 'package:server/db.dart';
import 'package:server/errors.dart';
import 'package:server/files.dart';
import 'package:server/notes.dart';

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  initDb('app.db'); // creates app.db + schema on first start
  initFileStorage('uploads'); // creates uploads/ on first start

  final router =
      Router(notFoundHandler: (Request r) => notFound('Route not found'))
        ..get('/health', (Request r) => jsonResponse({'status': 'ok'}))
        ..post('/auth/register', register)
        ..post('/auth/login', login)
        ..get('/me', requireAuth(me))
        // Notes: the example entity. Register your own routes the same way.
        ..get('/notes', requireAuth(listNotes))
        ..post('/notes', requireAuth(createNote))
        ..get('/notes/<id>', requireAuth(getNote))
        ..put('/notes/<id>', requireAuth(updateNote))
        ..delete('/notes/<id>', requireAuth(deleteNote))
        ..post('/files', requireAuth(uploadFile))
        ..get('/files/<id>', downloadFile);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors)
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('Backend listening on http://localhost:${server.port}');
}

// Permissive CORS so a Flutter *web* build can call the API during the labs.
const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
};

Handler _cors(Handler inner) => (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final response = await inner(request);
      return response.change(headers: _corsHeaders);
    };
