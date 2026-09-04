/// Firebase web configuration from Firebase Console.
class FirebaseWebConfig {
  const FirebaseWebConfig._();

  static const String apiKey = 'AIzaSyD1I95KKfloDM1G2BulHstckZ1nT17q040';
  static const String authDomain = 'quran-book-30ddf.firebaseapp.com';
  static const String databaseURL =
      'https://quran-book-30ddf-default-rtdb.firebaseio.com';
  static const String projectId = 'quran-book-30ddf';
  static const String storageBucket = 'quran-book-30ddf.firebasestorage.app';
  static const String messagingSenderId = '496161030293';
  static const String appId = '1:496161030293:web:5b68a408137a8d701e1b9c';
  static const String measurementId = 'G-XB5D3PT0SR';

  static const String signInWithPasswordUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword';
  static const String signUpUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp';
}

/// Optional proxy for auth + database in regions where Google/Firebase is blocked.
///
/// Deploy `tools/auth_proxy/` and set this URL when building:
/// `flutter run --dart-define=AUTH_PROXY_URL=https://your-proxy-url.com`
const String kAuthProxyBaseUrl = String.fromEnvironment(
  'AUTH_PROXY_URL',
  defaultValue: '',
);

/// True when a real proxy URL was provided at build time.
bool get isAuthProxyConfigured {
  final url = kAuthProxyBaseUrl.trim();
  if (url.isEmpty) return false;

  final lower = url.toLowerCase();
  if (lower.contains('your-proxy') ||
      lower.contains('example.com') ||
      lower.contains('placeholder')) {
    return false;
  }

  final uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.host.isNotEmpty;
}
