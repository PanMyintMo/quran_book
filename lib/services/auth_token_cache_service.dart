import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:quran_book/config/auth_config.dart';
import 'package:quran_book/services/app_cache_service.dart';

/// Persists Firebase Auth tokens from REST login so database reads work
/// when [FirebaseAuth.currentUser] / getIdToken() cannot reach Google.
class AuthTokenCacheService {
  static const _idTokenKey = 'auth_id_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _expiresAtKey = 'auth_expires_at';
  static const _uidKey = 'auth_uid';

  static bool _sessionActive = false;

  /// In-memory flag restored from disk on app start.
  static bool get hasActiveSession => _sessionActive;

  static Future<void> restoreSession() async {
    final token = await AppCacheService.loadRaw(_idTokenKey);
    _sessionActive = token != null && token.isNotEmpty;
  }

  static Future<void> saveSession({
    required String idToken,
    required String refreshToken,
    required int expiresInSeconds,
  }) async {
    final expiresAt =
        DateTime.now().add(Duration(seconds: expiresInSeconds)).millisecondsSinceEpoch;
    final uid = _uidFromIdToken(idToken);

    await Future.wait([
      AppCacheService.saveRaw(_idTokenKey, idToken),
      AppCacheService.saveRaw(_refreshTokenKey, refreshToken),
      AppCacheService.saveRaw(_expiresAtKey, expiresAt.toString()),
      if (uid != null) AppCacheService.saveRaw(_uidKey, uid),
    ]);
    _sessionActive = true;
  }

  static Future<void> clearSession() async {
    _sessionActive = false;
    await Future.wait([
      AppCacheService.saveRaw(_idTokenKey, ''),
      AppCacheService.saveRaw(_refreshTokenKey, ''),
      AppCacheService.saveRaw(_expiresAtKey, ''),
      AppCacheService.saveRaw(_uidKey, ''),
    ]);
  }

  static Future<bool> hasValidSession() async {
    final token = await getIdToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getCachedUid() async {
    return AppCacheService.loadRaw(_uidKey);
  }

  static Future<String?> getIdToken() async {
    final token = await AppCacheService.loadRaw(_idTokenKey);
    if (token == null || token.isEmpty) return null;

    final expiresRaw = await AppCacheService.loadRaw(_expiresAtKey);
    final expiresAt = int.tryParse(expiresRaw ?? '');
    if (expiresAt == null) return token;

    // Refresh if expiring within 5 minutes.
    if (DateTime.now().millisecondsSinceEpoch >= expiresAt - 300000) {
      final refreshed = await _refreshIdToken();
      return refreshed ?? token;
    }
    return token;
  }

  static Future<String?> _refreshIdToken() async {
    final refreshToken = await AppCacheService.loadRaw(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final dio = Dio();
      final response = await dio.post<Map<String, dynamic>>(
        'https://securetoken.googleapis.com/v1/token',
        queryParameters: {'key': FirebaseWebConfig.apiKey},
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      final idToken = response.data?['id_token'] as String?;
      final newRefresh = response.data?['refresh_token'] as String?;
      final expiresIn = int.tryParse('${response.data?['expires_in'] ?? 3600}') ?? 3600;

      if (idToken == null || idToken.isEmpty) return null;

      await saveSession(
        idToken: idToken,
        refreshToken: newRefresh ?? refreshToken,
        expiresInSeconds: expiresIn,
      );
      return idToken;
    } catch (_) {
      return null;
    }
  }

  static String? _uidFromIdToken(String idToken) {
    return _claimsFromIdToken(idToken)?['uid'];
  }

  static Future<Map<String, String>?> getCachedTokenClaims() async {
    final token = await getIdToken();
    if (token == null || token.isEmpty) return null;
    return _claimsFromIdToken(token);
  }

  static Map<String, String>? _claimsFromIdToken(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length < 2) return null;

      var payload = parts[1];
      final mod = payload.length % 4;
      if (mod > 0) {
        payload += '=' * (4 - mod);
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);
      if (map is! Map) return null;

      final uid = (map['user_id'] ?? map['sub'])?.toString();
      if (uid == null || uid.isEmpty) return null;

      return {
        'uid': uid,
        if (map['email'] != null) 'email': map['email'].toString(),
        if (map['name'] != null) 'name': map['name'].toString(),
        if (map['phone_number'] != null)
          'phone': map['phone_number'].toString(),
      };
    } catch (_) {
      return null;
    }
  }
}
