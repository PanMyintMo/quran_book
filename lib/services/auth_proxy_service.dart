import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quran_book/config/auth_config.dart';

/// Authenticates via a backend proxy when Firebase SDK cannot reach Google
/// directly (e.g. without VPN in some regions).
class AuthProxyService {
  AuthProxyService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  bool get isConfigured => isAuthProxyConfigured;

  Future<UserCredential> login(String email, String password) async {
    final baseUrl = kAuthProxyBaseUrl.trim();
    if (baseUrl.isEmpty) {
      throw StateError('Auth proxy URL is not configured');
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(
          contentType: Headers.jsonContentType,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final customToken = response.data?['customToken'] as String?;
      if (customToken == null || customToken.isEmpty) {
        throw Exception('Auth proxy returned an invalid response');
      }

      return await FirebaseAuth.instance.signInWithCustomToken(customToken);
    } on DioException catch (e) {
      final message = _extractProxyErrorMessage(e);
      throw FirebaseAuthException(code: 'auth-proxy-failed', message: message);
    }
  }

  Future<UserCredential> register(String email, String password) async {
    final baseUrl = kAuthProxyBaseUrl.trim();
    if (baseUrl.isEmpty) {
      throw StateError('Auth proxy URL is not configured');
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/register',
        data: {'email': email, 'password': password},
        options: Options(
          contentType: Headers.jsonContentType,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final customToken = response.data?['customToken'] as String?;
      if (customToken == null || customToken.isEmpty) {
        throw Exception('Auth proxy returned an invalid response');
      }

      return await FirebaseAuth.instance.signInWithCustomToken(customToken);
    } on DioException catch (e) {
      final message = _extractProxyErrorMessage(e);
      throw FirebaseAuthException(code: 'auth-proxy-failed', message: message);
    }
  }

  String _extractProxyErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        final message = error['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach auth server. Check your internet and try again.';
    }
    return 'Login failed. Please try again.';
  }
}
