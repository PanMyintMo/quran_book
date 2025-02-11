import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/welcome_page.dart';
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
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.navigateToNextPage(WelcomePage());
      }
    });
    super.initState();
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
