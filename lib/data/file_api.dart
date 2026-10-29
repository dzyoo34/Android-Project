import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class FileApi {
  FileApi(this.baseUrl, this.tokens);

  final String baseUrl;
  final TokenStore tokens;

  Future<Result<String>> upload(String path) async {
    try {
      final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/files'))
        ..headers['Authorization'] = 'Bearer ${await tokens.read() ?? ''}'
        ..files.add(await http.MultipartFile.fromPath('file', path));
      final res = await http.Response.fromStream(
          await req.send().timeout(const Duration(seconds: 20)));
      // timeout на send(): иначе зависший сервер не истечёт
      if (res.statusCode != 201) return Err(apiMessage(res));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Ok(data['url'] as String);
    } on SocketException {
      return Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return Err('Сервер не отвечает');
    } on FormatException {
      return Err('Ответ не тот, что обещан');
    } on TypeError {
      return Err('Ответ не тот, что обещан');
    }
  }
}