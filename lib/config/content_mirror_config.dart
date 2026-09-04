/// Public content mirror served via jsDelivr (GitHub CDN).
/// Updated automatically by .github/workflows/sync-firebase-content.yml
class ContentMirrorConfig {
  const ContentMirrorConfig._();

  static const String githubOwner = String.fromEnvironment(
    'CONTENT_MIRROR_OWNER',
    defaultValue: 'PanMyintMo',
  );

  static const String githubRepo = String.fromEnvironment(
    'CONTENT_MIRROR_REPO',
    defaultValue: 'quran_book',
  );

  static const String githubBranch = String.fromEnvironment(
    'CONTENT_MIRROR_BRANCH',
    defaultValue: 'master',
  );

  static const String publicDataPath = 'public_data';

  static String get jsDelivrBase =>
      'https://cdn.jsdelivr.net/gh/$githubOwner/$githubRepo@$githubBranch/$publicDataPath';

  static String get rawGitHubBase =>
      'https://raw.githubusercontent.com/$githubOwner/$githubRepo/$githubBranch/$publicDataPath';
}
