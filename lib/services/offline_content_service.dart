import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_book/data/vos/banner_vo.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/services/app_cache_service.dart';
import 'package:quran_book/services/storage_url_service.dart';

/// Downloads images to disk so banners/books work after one online sync.
class OfflineContentService {
  static const _readyKey = 'offline_content_ready';

  static Future<bool> isOfflineReady() async {
    final raw = await AppCacheService.loadRaw(_readyKey);
    return raw == 'true';
  }

  static Future<void> markOfflineReady() async {
    await AppCacheService.saveRaw(_readyKey, 'true');
  }

  static String _urlKey(String url) {
    return base64Url.encode(utf8.encode(url)).replaceAll('=', '');
  }

  static Future<String?> localPathForUrl(String url) async {
    if (url.trim().isEmpty) return null;
    return AppCacheService.loadRaw('img_${_urlKey(url)}');
  }

  static Future<void> prefetchHomeImages({
    required List<BookVO> books,
    required List<CategoryVO> categories,
    required List<BannerVO> banners,
  }) async {
    final urls = <String>{
      ...books.map((b) => b.image),
      ...categories.map((c) => c.image),
      ...banners.map((b) => b.image),
    }.where((u) => u.trim().isNotEmpty);

    final dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${dir.path}/offline_images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    for (final url in urls) {
      final key = _urlKey(url);
      final file = File('${imageDir.path}/$key');
      if (await file.exists()) {
        await AppCacheService.saveRaw('img_$key', file.path);
        continue;
      }

      for (final candidate in storageUrlCandidates(url)) {
        try {
          final response = await dio.get<List<int>>(
            candidate,
            options: Options(
              responseType: ResponseType.bytes,
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );
          if (response.statusCode == 200 && response.data != null) {
            await file.writeAsBytes(response.data!);
            await AppCacheService.saveRaw('img_$key', file.path);
            break;
          }
        } catch (_) {}
      }
    }

    if (books.isNotEmpty || categories.isNotEmpty || banners.isNotEmpty) {
      await markOfflineReady();
    }
  }
}
