import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/check_email_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSP20x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: kSP40x),
            EasyTextWidget(
              text: kForgetPasswordTitleText.tr(),
              fontSize: kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kForgetPasswordSubText.tr(),
              textColor: Colors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kSP20x),
            _buildTextField(
              kForgetPasswordEmailTitleText.tr(),
              kForgetPasswordEmailHintText.tr(),
            ),
            SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              width: double.infinity,
              backgroundColor: kAppPrimaryColor,
              height: kForgetPasswordButtonHeight,
              onPressed: () {
                context.navigateToNextPage(CheckEmailPage());
              },
              buttonText: kSubmit.tr(),
              buttonTextColor: kWhiteColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EasyTextWidget(text: label, fontWeight: FontWeight.bold),
        SizedBox(height: kSP10x),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kSP10x),
            ),
          ),
        ),
      ],
    );
  }
}
