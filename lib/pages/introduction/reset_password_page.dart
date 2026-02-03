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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

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
              text: kCreateNewPasswordText.tr(),
              fontSize: kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kCreateNewPasswordSubText.tr(),
              textColor: Colors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kSP20x),

            /// New Password
            _buildPasswordField(
              label: kCreateNewPasswordTitleText.tr(),
              hintText: kCreateNewPasswordTitleHintText.tr(),
              obscureText: _obscureNewPassword,
              onToggle: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),

            SizedBox(height: kSP20x),

            /// Confirm Password
            _buildPasswordField(
              label: kCreateNewPasswordRepeatTitleText.tr(),
              hintText: kCreateNewPasswordRepeatTitleHintText.tr(),
              obscureText: _obscureConfirmPassword,
              onToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),

            SizedBox(height: kSP20x),

            PrimaryButtonWidget(
              width: double.infinity,
              backgroundColor: kAppPrimaryColor,
              height: kResetPasswordSubmitHeight,
              onPressed: () {
                context.navigateToNextPageWithRemoveUntil(LoginPage());
              },
              buttonText: kSubmit.tr(),
              buttonTextColor: kWhiteColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EasyTextWidget(text: label, fontWeight: FontWeight.bold),
        SizedBox(height: kSP10x),
        TextField(
          obscureText: obscureText,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
