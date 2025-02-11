import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
              Image.asset(
                AssetImageUtils.kAppIcon,
                height: kResetPasswordAppIconHeight,
              ),
              SizedBox(height: kSP20x),
              EasyTextWidget(
                text: kRegisterCreateYourAccountText.tr(),
                fontSize: kFontSize22x,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: kSP10x),
              EasyTextWidget(
                text: kRegisterSubText.tr(),
                textColor: Colors.grey,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: kSP20x),
              _buildTextField(kRegisterNameTitleText.tr(), kRegisterNameHintText.tr()),
              SizedBox(height: kSP20x),
              _buildTextField(kRegisterEmailTitleText.tr(), kRegisterEmailHintText.tr()),
              SizedBox(height: kSP20x),
              _buildPasswordField(kRegisterPasswordTitleText.tr(), kRegisterPasswordHintText.tr()),
              SizedBox(height: kSP20x),
              _buildPasswordField(kRegisterRepeatPasswordTitleText.tr(), kRegisterRepeatPasswordHintText.tr()),
              SizedBox(height: kSP20x),
              PrimaryButtonWidget(
                width: double.infinity,
                height: kLoginPageButtonHeight,
                backgroundColor: kAppPrimaryColor,
                onPressed: () {},
                buttonTextColor: kWhiteColor,
                buttonText: kLogin.tr(),
              ),
              SizedBox(height: kSP20x),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSP10x),
                    child: EasyTextWidget(text: kRegisterContinueWithText),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: kSP20x),
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
                  EasyTextWidget(text: kRegisterAlreadyAccountText.tr()),
                  TextButton(
                    onPressed: () {
                      context.navigateToNextPageWithReplacement(LoginPage());
                    },
                    child: EasyTextWidget(
                      text: kRegisterSignUpText.tr(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildPasswordField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: kSP10x),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kSP10x),
            ),
            suffixIcon: Icon(Icons.visibility_off),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButton(String label, String assetPath) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kWhiteColor,
        side: BorderSide(
          color: kBlackColor,
        ),
        minimumSize: Size(kGoogleAppleButtonWidth, kGoogleAppleButtonHeight),
      ),
      onPressed: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, height: kGoogleAppleImageHeight),
          SizedBox(
            width: kSP10x,
          ),
          EasyTextWidget(
            text: label,
            textColor: kBlackColor,
          ),
        ],
      ),
    );
  }
}
