import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _key = 'auth_token';
  static const _emailKey = 'user_email';

  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  Future<String?> readEmail() async =>
      (await SharedPreferences.getInstance()).getString(_emailKey);

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key); // logout и 401: мёртвый пропуск выбрасывают
    await prefs.remove(_emailKey);
  }
}