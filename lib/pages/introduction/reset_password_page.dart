import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:quran_book/pages/introduction/check_email_page.dart';
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
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      context.showErrorSnackBar("Please enter your email address");
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      context.showErrorSnackBar("Please enter a valid email address");
      return;
    }

    try {
      Logger().d("Sending reset email to $email");
      context.showLoadingDialog();

      final actionCodeSettings = ActionCodeSettings(
        url: 'https://quran-book-30ddf.firebaseapp.com',
        handleCodeInApp: true,
        androidPackageName: 'com.example.quran_book',
        androidInstallApp: true,
        androidMinimumVersion: '21',
        iOSBundleId: 'com.example.quranBook',
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      if (mounted) {
        Logger().d("Password reset email sent to $email");
        context.hideLoadingDialog();
        context.navigateToNextPageWithReplacement(const CheckEmailPage());
      }
    } on FirebaseAuthException catch (e) {
      Logger().e("Failed to send password reset email: ${e.message}");
      if (mounted) {
        context.hideLoadingDialog();
        String msg;
        switch (e.code) {
          case 'user-not-found':
            msg = "No account found with this email address.";
            break;
          case 'invalid-email':
            msg = "Invalid email address.";
            break;
          default:
            msg = e.message ?? "Failed to send reset email.";
        }
        context.showErrorSnackBar(msg);
      }
    } catch (e) {
      Logger().e("Failed to send password reset email: ${e.toString()}");
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: kSP20x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: kSP40x),
            Image.asset(
              AssetImageUtils.kAppIcon,
              height: kResetPasswordAppIconHeight,
            ),
            const SizedBox(height: kSP20x),
            EasyTextWidget(
              text: kForgetPasswordTitleText.tr(),
              fontSize: kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kForgetPasswordSubText.tr(),
              textColor: Colors.grey,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSP20x),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EasyTextWidget(
                  text: kForgetPasswordEmailTitleText.tr(),
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: kSP10x),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: kForgetPasswordEmailHintText.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              width: double.infinity,
              backgroundColor: kAppPrimaryColor,
              height: kResetPasswordSubmitHeight,
              onPressed: _sendResetEmail,
              buttonText: "Send Reset Link",
              buttonTextColor: kWhiteColor,
            ),
            const SizedBox(height: kSP20x),
            TextButton(
              onPressed: () {
                context.navigateToNextPageWithRemoveUntil(const LoginPage());
              },
              child: EasyTextWidget(
                text: "Back to Login",
                textColor: isDarkMode ? kWhiteColor : kAppPrimaryColor,
              ),
            ),
            const SizedBox(height: kSP40x),
          ],
        ),
      ),
    );
  }
}
