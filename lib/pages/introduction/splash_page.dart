import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/pages/admin/admin_home_page.dart';
import 'package:quran_book/pages/introduction/welcome_page.dart';
import 'package:quran_book/pages/main_page/index_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    // 🔹 User not logged in → Welcome
    if (!_firebaseModel.isLoggedIn()) {
      if (mounted) {
        context.navigateToNextPageWithRemoveUntil(const WelcomePage());
      }
      return;
    }

    try {
      // 🔹 Fetch ONLY current user (no permission issue)
      final currentUser = await _firebaseModel.getCurrentUserVO();

      if (!mounted) return;

      if (currentUser == null) {
        context.navigateToNextPageWithRemoveUntil(const WelcomePage());
        return;
      }

      // 🔹 Admin / Normal user routing
      if (currentUser.isAdmin) {
        context.navigateToNextPageWithRemoveUntil(const AdminHomePage());
      } else {
        context.navigateToNextPageWithRemoveUntil(const IndexPage());
      }
    } catch (e) {
      // 🔹 Safety fallback
      if (mounted) {
        context.navigateToNextPageWithRemoveUntil(const WelcomePage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppPrimaryColor,
      body: Center(
        child: Image.asset(
          AssetImageUtils.kAppIcon,
          width: kSplashAppIconSize,
          height: kSplashAppIconSize,
        ),
      ),
    );
  }
}
