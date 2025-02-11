import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/forget_password_page.dart';
import 'package:quran_book/pages/introduction/register_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSP20x),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: kSP60x),
              Image.asset(AssetImageUtils.kAppIcon, height: 80),
              SizedBox(height: kSP20x),
              EasyTextWidget(
                text: kLoginWelcomeText.tr(),
                fontSize: kFontSize22x,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: kSP10x),
              EasyTextWidget(
                text: kLoginSubText.tr(),
                textColor: Colors.grey,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: kSP20x),
              Align(
                alignment: Alignment.centerLeft,
                child: EasyTextWidget(
                  text: kLoginEmailText.tr(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: kSP10x),
              TextField(
                decoration: InputDecoration(
                  hintText: kLoginEmailHintText.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kSP10x),
                  ),
                ),
              ),
              SizedBox(height: kSP20x),
              Align(
                alignment: Alignment.centerLeft,
                child: EasyTextWidget(
                  text: kLoginPasswordText.tr(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: kSP10x),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: kLoginPasswordHintText.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kSP10x),
                  ),
                  suffixIcon: Icon(Icons.visibility_off),
                ),
              ),
              SizedBox(height: kSP10x),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    context.navigateToNextPage(ForgotPasswordPage());
                  },
                  child: EasyTextWidget(
                    text: kLoginForgetPasswordLabelText.tr(),
                    textColor: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: kSP20x),
              PrimaryButtonWidget(
                width: double.infinity,
                height: kLoginPageButtonHeight,
                onPressed: () {},
                buttonText: kLogin.tr(),
                buttonTextColor: Colors.white,
              ),
              SizedBox(height: kSP10x),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSP10x),
                    child: EasyTextWidget(
                      text: kLoginOrLoginWithText.tr(),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: kSP10x),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialLoginButton(
                    kGoogle.tr(),
                    AssetImageUtils.kGoogleIcon,
                  ),
                  SizedBox(width: kSP20x),
                  _buildSocialLoginButton(
                    kApple.tr(),
                    AssetImageUtils.kAppleIcon,
                  ),
                ],
              ),
              SizedBox(height: kSP20x),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EasyTextWidget(text: kLoginDoNoHaveAnAccountText.tr()),
                  PrimaryButtonWidget(
                    buttonText: kRegister.tr(),
                    buttonFontWeight: FontWeight.bold,
                    onPressed: () {
                      context.navigateToNextPageWithReplacement(RegisterPage());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton(String label, String assetPath) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kWhiteColor,
        side: BorderSide(color: kBlackColor),
        minimumSize: Size(kGoogleAppleButtonWidth, kGoogleAppleButtonHeight),
      ),
      onPressed: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, height: kGoogleAppleImageHeight),
          SizedBox(width: kSP10x),
          EasyTextWidget(
            text: label,
            textColor: kBlackColor,
          ),
        ],
      ),
    );
  }
}
