import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quran_book/config/auth_config.dart';
import 'package:quran_book/services/auth_token_cache_service.dart';

/// Signs in using Firebase Auth REST API with the web API key.
class FirebaseRestAuthService {
  FirebaseRestAuthService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        FirebaseWebConfig.signInWithPasswordUrl,
        queryParameters: {'key': FirebaseWebConfig.apiKey},
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      await _persistSession(response.data);
      await _tryEstablishSdkSession(email, password);
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Login failed. Please try again.');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        FirebaseWebConfig.signUpUrl,
        queryParameters: {'key': FirebaseWebConfig.apiKey},
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      await _persistSession(response.data);
      await _tryEstablishSdkSession(email, password);
    } on DioException catch (e) {
      throw _mapDioError(e, fallbackMessage: 'Registration failed. Please try again.');
    }
  }

  Future<void> _persistSession(Map<String, dynamic>? data) async {
    final idToken = data?['idToken'] as String?;
    final refreshToken = data?['refreshToken'] as String?;
    final expiresIn = int.tryParse('${data?['expiresIn'] ?? 3600}') ?? 3600;

    if (idToken == null ||
        idToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-response',
        message: 'Authentication failed. Please try again.',
      );
    }

    await AuthTokenCacheService.saveSession(
      idToken: idToken,
      refreshToken: refreshToken,
      expiresInSeconds: expiresIn,
    );
  }

  Future<void> _tryEstablishSdkSession(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // REST session is cached; database reads can use the stored idToken.
    }
  }

  FirebaseAuthException _mapDioError(
    DioException e, {
    required String fallbackMessage,
  }) {
    final data = e.response?.data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        final message = error['message']?.toString() ?? '';
        return FirebaseAuthException(
          code: _mapRestMessageToCode(message),
          message: message.isNotEmpty ? message : fallbackMessage,
        );
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Connection timed out. Please try again.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Network error. Check your internet and try again.',
      );
    }

    return FirebaseAuthException(
      code: 'auth-failed',
      message: fallbackMessage,
    );
  }

  String _mapRestMessageToCode(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('email already in use') ||
        lower.contains('email address is already')) {
      return 'email-already-in-use';
    }
    if (lower.contains('password') && lower.contains('invalid')) {
      return 'wrong-password';
    }
    if (lower.contains('email not found') ||
        lower.contains('no user') ||
        lower.contains('user not found')) {
      return 'user-not-found';
    }
    if (lower.contains('invalid email')) {
      return 'invalid-email';
    }
    if (lower.contains('too many')) {
      return 'too-many-requests';
    }
    return 'invalid-credential';
  }
}
