import 'package:package_info_plus/package_info_plus.dart';

class GetPackageInfoUtils {
  static Future<String> getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;

    return version;
  }
}
