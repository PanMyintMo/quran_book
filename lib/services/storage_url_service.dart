import 'package:quran_book/config/auth_config.dart';

/// Rewrites Firebase Storage URLs through the auth proxy when configured.
String resolveStorageUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;

  if (!isAuthProxyConfigured) return trimmed;

  final lower = trimmed.toLowerCase();
  final isFirebaseStorage = lower.contains('firebasestorage.googleapis.com') ||
      lower.contains('firebasestorage.app') ||
      lower.contains('storage.googleapis.com');

  if (!isFirebaseStorage) return trimmed;

  final proxy = kAuthProxyBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  return '$proxy/storage?url=${Uri.encodeComponent(trimmed)}';
}

/// Proxy first, then direct URL — direct works when VPN is on.
List<String> storageUrlCandidates(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return const [];

  final candidates = <String>[];
  if (isAuthProxyConfigured) {
    candidates.add(resolveStorageUrl(trimmed));
  }
  if (!candidates.contains(trimmed)) {
    candidates.add(trimmed);
  }
  return candidates;
}
