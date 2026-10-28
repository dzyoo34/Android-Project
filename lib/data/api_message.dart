import 'dart:convert';
import 'package:http/http.dart' as http;


String apiMessage(http.Response res) {
  try {
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final error = data['error'] as Map<String, dynamic>;
    final code = error['code'] as String;
    switch (code) {
      case 'VALIDATION_ERROR':
        return 'Отправленные данные недействительны';
      case 'UNAUTHORIZED':
        return 'Неверный email или пароль';
      case 'EMAIL_TAKEN':
        return 'Аккаунт с этим email уже существует';
      case 'NOT_FOUND':
        return 'Запись не существует';
      default:
        return 'Ошибка сервера ($code)';
    }
  } on FormatException {
    return 'Ошибка сервера (${res.statusCode})';
  } on TypeError {
    return 'Ошибка сервера (${res.statusCode})';
  }
}