import 'dart:math' as logger;

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _emailVerified = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
        setState(() {
          _emailVerified = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      Logger().e("Failed to send password reset email: ${e.message}");
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed: ${e.message}");
      }
    } catch (e) {
      Logger().e("Failed to send password reset email: ${e.toString()}");
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed: ${e.toString()}");
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      context.showErrorSnackBar("Please fill all fields");
      return;
    }

    if (newPassword != confirmPassword) {
      context.showErrorSnackBar("Passwords do not match");
      return;
    }

    if (newPassword.length < 6) {
      context.showErrorSnackBar("Password must be at least 6 characters");
      return;
    }

    try {
      context.showLoadingDialog();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        if (mounted) {
          context.hideLoadingDialog();
          context.showSuccessSnackBar("Password updated successfully");
          context.navigateToNextPageWithRemoveUntil(const LoginPage());
        }
      } else {
        if (mounted) {
          context.hideLoadingDialog();
          context.showSuccessSnackBar("Please use the link sent to your email to reset your password");
          context.navigateToNextPageWithRemoveUntil(const LoginPage());
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed: ${e.message}");
      }
    } catch (e) {
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
            SizedBox(height: kSP40x),
            Image.asset(
              AssetImageUtils.kAppIcon,
              height: kResetPasswordAppIconHeight,
            ),
            SizedBox(height: kSP20x),
            EasyTextWidget(
              text: kForgetPasswordTitleText.tr(),
              fontSize: kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: _emailVerified
                  ? "We've sent a password reset link to your email. You can also set a new password below if you're logged in."
                  : kForgetPasswordSubText.tr(),
              textColor: Colors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kSP20x),

            /// Email Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EasyTextWidget(
                  text: kForgetPasswordEmailTitleText.tr(),
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: kSP10x),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: kForgetPasswordEmailHintText.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ],
            ),

            SizedBox(height: kSP20x),

            PrimaryButtonWidget(
              width: double.infinity,
              backgroundColor: kAppPrimaryColor,
              height: kResetPasswordSubmitHeight,
              onPressed: _sendResetEmail,
              buttonText: "Send Reset Link",
              buttonTextColor: kWhiteColor,
            ),

            if (_emailVerified) ...[
              SizedBox(height: kSP30x),
              Divider(),
              SizedBox(height: kSP20x),
              EasyTextWidget(
                text: "Or update password directly (if logged in)",
                textColor: Colors.grey,
                fontSize: kFontSize12x,
              ),
              SizedBox(height: kSP20x),

              /// New Password
              _buildPasswordField(
                controller: _newPasswordController,
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
                controller: _confirmPasswordController,
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
                onPressed: _handlePasswordReset,
                buttonText: kSubmit.tr(),
                buttonTextColor: kWhiteColor,
              ),
            ],

            SizedBox(height: kSP20x),

            TextButton(
              onPressed: () {
                context.navigateToNextPageWithRemoveUntil(const LoginPage());
              },
              child: EasyTextWidget(
                text: "Back to Login",
                textColor: isDarkMode ? kWhiteColor : kAppPrimaryColor,
              ),
            ),

            SizedBox(height: kSP40x),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
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
          controller: controller,
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
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
