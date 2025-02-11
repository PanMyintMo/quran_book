import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/on_boarding_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AssetImageUtils.kWelcomeBackgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.15,
                right: MediaQuery.of(context).size.width * 0.1,
              ),
              child: EasyTextWidget(
                textAlign: TextAlign.center,
                fontFamily: kAgbalumoFont,
                text: kWelcomeToText.tr(),
                textColor: kWhiteColor,
                fontSize: kFontSize40x,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: kSP10x,
              ),
              child: PrimaryButtonWidget(
                radius: kSP10x,
                width: kWelcomeNextButtonWidth,
                height: kWelcomeNextButtonHeight,
                backgroundColor: kAppYellowButtonColor,
                onPressed: () {
                  context.navigateToNextPage(OnBoardingPage());
                },
                buttonText: kNext.tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
