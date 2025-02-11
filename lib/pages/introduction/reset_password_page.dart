import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kWhiteColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSP20x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: kSP40x),
            Image.asset(
              AssetImageUtils.kAppIcon,
              height: kResetPasswordAppIconHeight,
            ),
            SizedBox(height: kSP20x),
            EasyTextWidget(
              text: kCreateNewPasswordText,
              fontSize: kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kCreateNewPasswordSubText,
              textColor: Colors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kSP20x),
            _buildPasswordField(kCreateNewPasswordTitleText, kCreateNewPasswordTitleHintText),
            SizedBox(height: kSP20x),
            _buildPasswordField(kCreateNewPasswordRepeatTitleText, kCreateNewPasswordRepeatTitleHintText),
            SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              width: double.infinity,
              backgroundColor: kAppPrimaryColor,
              height: kResetPasswordSubmitHeight,
              onPressed: () {
                context.navigateToNextPageWithRemoveUntil(LoginPage());
              },
              buttonText: kSubmit,
              buttonTextColor: kWhiteColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EasyTextWidget(text: label, fontWeight: FontWeight.bold),
        SizedBox(height: kSP10x),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: Icon(Icons.visibility_off),
          ),
        ),
      ],
    );
  }
}
