import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/reset_password_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSP20x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: kSP40x),
            Icon(Icons.email, size: kCheckEmailIconSize, color: Colors.black),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kCheckYourEmailLabelText.tr(),
              fontSize: kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kCheckYourEmailSentText.tr(),
              textColor: Colors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              backgroundColor: kAppPrimaryColor,
              height: kCheckEmailResetButtonHeight,
              onPressed: () {
                context.navigateToNextPage(ResetPasswordPage());
              },
              buttonText: kCheckYourEmailResendEmailText.tr(),
              buttonTextColor: kWhiteColor,
            ),
            SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              backgroundColor: kAppPrimaryColor,
              height: kCheckEmailResetButtonHeight,
              onPressed: () {
                context.navigateToNextPage(ResetPasswordPage());
              },
              buttonText: kCheckYourEmailOpenEmailText.tr(),
              buttonTextColor: kWhiteColor,
            ),
            SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              onPressed: () {},
              buttonText: kCheckYourEmailDidNotGetText.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
