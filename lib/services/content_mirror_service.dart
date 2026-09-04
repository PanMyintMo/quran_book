import 'package:dio/dio.dart';
import 'package:quran_book/config/content_mirror_config.dart';

/// Loads books/categories/banners from jsDelivr (GitHub mirror).
/// Works in regions where Google/Firebase/Vercel are blocked.
class ContentMirrorService {
  ContentMirrorService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<T>> fetchList<T>(
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
          final list = _parseListMap(response.data, fromJson);
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
    }
    return <T>[];
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
      return data
          .whereType<Map>()
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (data is Map) {
      return data.entries
          .where((entry) => entry.value is Map)
          .map(
            (entry) => fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ),
          )
          .toList();
    }

    return <T>[];
  }
}
