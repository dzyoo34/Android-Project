import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

// register или login по контракту; token уходит в TokenStore.
class AuthApi {
  AuthApi(this.baseUrl, this.tokens);

  final String baseUrl;
  final TokenStore tokens;
  static const _timeout = Duration(seconds: 8);

  Future<Result<void>> register(String email, String password, String name) =>
      _post('/auth/register',
          {'email': email, 'password': password, 'name': name});

  Future<Result<void>> login(String email, String password) =>
      _post('/auth/login', {'email': email, 'password': password});

  Future<void> logout() => tokens.clear();

  Future<Result<void>> _post(String path, Map<String, Object?> body) async {
    try {
      final res = await http
          .post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(_timeout);
      if (res.statusCode != 200 && res.statusCode != 201) {
        return Err(apiMessage(res));
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await tokens.save(data['token'] as String);
      await tokens.saveEmail(body['email'] as String);
      return const Ok(null);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что нужен');
    } on TypeError {
      return const Err('Ответ не тот, что нужен');
    }
  }
}