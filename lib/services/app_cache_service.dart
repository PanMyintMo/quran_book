import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists Firebase lists locally so the app works when Google is blocked.
class AppCacheService {
  static Future<List<T>> loadList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cache_$key');
      if (raw == null || raw.isEmpty) return <T>[];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return <T>[];

      return decoded
          .whereType<Map>()
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return <T>[];
    }
  }

  static Future<void> saveList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_$key', jsonEncode(items));
    } catch (_) {
      // Cache write failure should not break the app.
    }
  }

  static Future<void> saveRaw(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_$key', value);
    } catch (_) {}
  }

  static Future<String?> loadRaw(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('cache_$key');
    } catch (_) {
      return null;
    }
  }
}
