import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_message.dart';
import 'client.dart';
import 'client_repository.dart';
import 'result.dart';
import 'token_store.dart';

class HttpClientRepository implements ClientRepository {
  HttpClientRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await tokens.read() ?? ''}',
  };

  // 401 = пропуск умер: token выбрасывается, корень навигирует
  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }

  Future<Result<T>> _call<T>(
      Future<http.Response> Function(Map<String, String> headers) send,
      int okStatus,
      T Function(http.Response res) parse,
      ) async {
    try {
      final res = await send(await _headers()).timeout(_timeout);
      if (res.statusCode == 401) return Err(await _sessionDied());
      if (res.statusCode != okStatus) return Err(apiMessage(res)); // слой 2
      return Ok(parse(res));
    } on SocketException {
      return Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return Err('Сервер не отвечает');
    } on FormatException {
      return Err('Ответ не тот, что нужен');
    } on TypeError {
      return Err('Ответ не тот, что нужен');
    }
  }

  @override
  Future<Result<List<Client>>> fetchAll(
      {int page = 1, int limit = 20, String? search}) {
    final uri = Uri.parse('$baseUrl/clients').replace(queryParameters: {
      'page': '$page',
      'limit': '$limit',
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return _call(
          (h) => http.get(uri, headers: h),
      200,
          (res) {
        final data = jsonDecode(res.body) as Map<String, dynamic>; // конверт
        return (data['items'] as List)
            .map((e) => Client.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<Result<Client>> fetchById(int id) {
    final uri = Uri.parse('$baseUrl/clients/$id');
    return _call(
          (h) => http.get(uri, headers: h),
      200,
          (res) => Client.fromJson(jsonDecode(res.body) as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<Client>> create(Client client) {
    final uri = Uri.parse('$baseUrl/clients');
    return _call(
          (h) => http.post(uri, headers: h, body: jsonEncode(client.toJson())),
      201,
          (res) => Client.fromJson(jsonDecode(res.body) as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<Client>> update(Client client) {
    final uri = Uri.parse('$baseUrl/clients/${client.id}');
    return _call(
          (h) => http.put(uri, headers: h, body: jsonEncode(client.toJson())),
      200,
          (res) => Client.fromJson(jsonDecode(res.body) as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<void>> delete(int id) {
    final uri = Uri.parse('$baseUrl/clients/$id');
    return _call<void>(
          (h) => http.delete(uri, headers: h),
      204,
          (_) {},
    );
  }
}