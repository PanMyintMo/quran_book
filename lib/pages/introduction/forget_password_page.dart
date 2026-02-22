import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:quran_book/pages/introduction/check_email_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Logger().e("Please enter your email address");
      context.showErrorSnackBar("Please enter your email address");
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      Logger().e("Please enter a valid email address");
      context.showErrorSnackBar("Please enter a valid email address");
      return;
    }

    try {
      Logger().d("Sending reset email to $email");
      context.showLoadingDialog();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        Logger().d("Password reset email sent! Check your inbox.");
        context.hideLoadingDialog();
        context.showSuccessSnackBar("Password reset email sent! Check your inbox.");
        // Navigate to check email page after successful send
        context.navigateToNextPage(const CheckEmailPage());
      }
    } on FirebaseAuthException catch (e) {
      Logger().e("Failed to send password reset email: ${e.message}");
      if (mounted) {
        context.hideLoadingDialog();
        String errorMessage = "Failed to send reset email";
        if (e.code == 'user-not-found') {
          errorMessage = "No account found with this email address";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email address";
        } else {
          errorMessage = "Failed: ${e.message}";
        }
        context.showErrorSnackBar(errorMessage);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSP20x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: kSP40x),
            EasyTextWidget(
              text: kForgetPasswordTitleText.tr(),
              fontSize: isDarkMode ? kFontSize22x : kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kForgetPasswordSubText.tr(),
              textColor: isDarkMode ? kWhiteColor : Colors.grey,
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
              backgroundColor: isDarkMode ? kAppPrimaryColor : kWhiteColor,
              height: kForgetPasswordButtonHeight,
              onPressed: _sendResetEmail,
              buttonText: kSubmit.tr(),
              buttonTextColor: isDarkMode ? kWhiteColor : kAppPrimaryColor,
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
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kSP10x),
            ),
            suffixIcon: Icon(Icons.email_outlined),
          ),
        ),
      ],
    );
  }
}
