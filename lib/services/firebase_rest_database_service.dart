import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quran_book/config/auth_config.dart';
import 'package:quran_book/services/auth_token_cache_service.dart';

/// Reads/writes Realtime Database via REST when the Firebase SDK is blocked.
class FirebaseRestDatabaseService {
  FirebaseRestDatabaseService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<Map<String, dynamic>?> fetchObject(String path) async {
    try {
      final data = await _request(path, method: 'GET');
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<T>> fetchList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final data = await _request(path, method: 'GET');
      return _parseListMap(data, fromJson);
    } catch (_) {
      return <T>[];
    }
  }

  Future<bool> setValue(String path, Map<String, dynamic> data) async {
    try {
      await _request(path, method: 'PUT', body: data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _authToken() async {
    final cached = await AuthTokenCacheService.getIdToken();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      return await user.getIdToken().timeout(const Duration(seconds: 5));
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> _request(
    String path, {
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final token = await _authToken();
    final errors = <Object>[];

    for (final url in _buildUrls(path, token)) {
      try {
        final response = await _dio.request<dynamic>(
          url,
          data: body,
          options: Options(
            method: method,
            contentType: Headers.jsonContentType,
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          return response.data;
        }
      } catch (e) {
        errors.add(e);
      }
    }

    if (errors.isNotEmpty && !isAuthProxyConfigured) {
      throw errors.last;
    }
    return null;
  }

  List<String> _buildUrls(String path, String? token) {
    final normalizedPath = path.replaceAll(RegExp(r'^/+|/+$'), '');
    final urls = <String>[];

    final proxy = isAuthProxyConfigured ? kAuthProxyBaseUrl.trim() : '';
    if (proxy.isNotEmpty) {
      final proxyBase = proxy.replaceAll(RegExp(r'/+$'), '');
      if (token != null) {
        urls.add('$proxyBase/db/$normalizedPath.json?auth=$token');
      }
      urls.add('$proxyBase/db/$normalizedPath.json');
    }

    // Always keep direct Firebase as fallback (works when VPN is on).
    final databaseBase =
        '${FirebaseWebConfig.databaseURL}/$normalizedPath.json';
    if (token != null) {
      urls.add('$databaseBase?auth=$token');
    }
    urls.add(databaseBase);
    return urls;
  }

  List<T> _parseListMap<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data == null) return <T>[];
    if (data is! Map) return <T>[];

    return data.entries
        .where((entry) => entry.value is Map)
        .map(
          (entry) => fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          ),
        )
        .toList();
  }
}
