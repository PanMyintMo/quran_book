import 'package:shared_preferences/shared_preferences.dart';

class Sharepreference {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences once
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set a theme mode
  static Future<void> setThemeMode(String key, bool darkMode) async {
    await _prefs?.setBool(key, darkMode);
  }

  // Get the theme mode
  static bool? getThemeMode(String key) {
    return _prefs?.getBool(key);
  }
}
