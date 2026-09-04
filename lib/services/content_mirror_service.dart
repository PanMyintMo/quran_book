import 'package:dio/dio.dart';
import 'package:quran_book/config/content_mirror_config.dart';

/// Loads books/categories/banners from jsDelivr (GitHub mirror).
/// Works in regions where Google/Firebase/Vercel are blocked.
class ContentMirrorService {
  ContentMirrorService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Returns [null] when no mirror URL responded (404/network).
  /// Returns an empty list when the mirror file exists but has no items yet.
  Future<List<T>?> fetchList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    for (final url in _listUrls(path)) {
      try {
        final response = await _dio.get<dynamic>(
          url,
          options: Options(
            sendTimeout: const Duration(seconds: 25),
            receiveTimeout: const Duration(seconds: 25),
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          return _parseListMap(response.data, fromJson);
        }
      } catch (_) {}
    }
    return null;
  }

  List<String> _listUrls(String path) {
    final normalized = path.replaceAll(RegExp(r'^/+|/+$'), '');
    return [
      '${ContentMirrorConfig.jsDelivrBase}/$normalized.json',
      '${ContentMirrorConfig.rawGitHubBase}/$normalized.json',
    ];
  }

  List<T> _parseListMap<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data == null) return <T>[];

    if (data is List) {
      final items = <T>[];
      for (final item in data) {
        if (item is! Map) continue;
        try {
          items.add(fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
      return items;
    }

    if (data is Map) {
      final items = <T>[];
      for (final entry in data.entries) {
        if (entry.value is! Map) continue;
        try {
          items.add(
            fromJson(Map<String, dynamic>.from(entry.value as Map)),
          );
        } catch (_) {}
      }
      return items;
    }

    return <T>[];
  }
}
