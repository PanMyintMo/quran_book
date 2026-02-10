import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
          context.showErrorSnackBar("Please login first to change password");
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
