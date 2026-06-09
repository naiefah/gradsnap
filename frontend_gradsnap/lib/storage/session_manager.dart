import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  static Future<void> saveLogin(
    String username,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool('isLogin', true);

    await prefs.setString(
      'username',
      username,
    );
  }

  static Future<bool> isLogin() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool('isLogin') ?? false;
  }

  static Future<String> getUsername() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('username') ?? '';
  }

  static Future<void> logout() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }
}