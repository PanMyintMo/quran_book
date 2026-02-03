import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/pages/main_page/index_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppPrimaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(kSP20x),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.1,
              ),
              Image.asset(
                AssetImageUtils.kOnBoardingImage,
              ),
              SizedBox(
                height: kSP40x,
              ),
              EasyTextWidget(
                text: 'Welcome',
                fontWeight: FontWeight.bold,
                textColor: kWhiteColor,
                fontSize: kFontSize32x,
              ),
              SizedBox(
                height: kSP20x,
              ),
              EasyTextWidget(
                text: kOnBoardingDescriptionText.tr(),
                fontWeight: FontWeight.w600,
                textColor: kWhiteColor,
                fontSize: kFontSize12x,
              ),
              SizedBox(
                height: kSP40x,
              ),
              PrimaryButtonWidget.ghostButton(
                radius: kSP10x,
                width: double.infinity,
                height: kOnBoardingButtonHeight,
                buttonText: kOnBoardingReadDirectText.tr(),
                buttonTextColor: kWhiteColor,
                buttonFontWeight: FontWeight.w600,
                onPressed: () {
                  context.navigateToNextPageWithRemoveUntil(IndexPage());
                },
              ),
              SizedBox(
                height: kSP20x,
              ),
              PrimaryButtonWidget(
                radius: kSP10x,
                width: double.infinity,
                height: kOnBoardingButtonHeight,
                buttonText: kLogin.tr(),
                backgroundColor: kWhiteColor,
                buttonFontWeight: FontWeight.w600,
                onPressed: () {
                  context.navigateToNextPage(LoginPage());
                },
              ),
              SizedBox(
                height: kSP40x,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
