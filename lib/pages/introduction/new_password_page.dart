import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class NewPasswordPage extends StatefulWidget {
  final String oobCode;

  const NewPasswordPage({super.key, required this.oobCode});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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

      // Verify the code is still valid (codes expire after 1 hour)
      await FirebaseAuth.instance.verifyPasswordResetCode(widget.oobCode);

      // Apply the new password
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: newPassword,
      );

      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar("Password reset successfully! Please login.");
        context.navigateToNextPageWithRemoveUntil(const LoginPage());
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        String msg;
        switch (e.code) {
          case 'expired-action-code':
            msg = "Reset link has expired. Please request a new one.";
            break;
          case 'invalid-action-code':
            msg = "Invalid reset link. Please request a new one.";
            break;
          case 'weak-password':
            msg = "Password is too weak. Use at least 6 characters.";
            break;
          default:
            msg = e.message ?? "Failed to reset password.";
        }
        context.showErrorSnackBar(msg);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kSP40x),
            EasyTextWidget(
              text: "Set New Password",
              fontSize: kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: kSP10x),
            EasyTextWidget(
              text: "Enter your new password below.",
              textColor: Colors.grey,
            ),
            const SizedBox(height: kSP30x),
            _buildPasswordField(
              controller: _newPasswordController,
              label: "New Password",
              hintText: "Enter new password",
              obscureText: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: kSP20x),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: "Confirm Password",
              hintText: "Re-enter new password",
              obscureText: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: kSP30x),
            PrimaryButtonWidget(
              width: double.infinity,
              backgroundColor: kAppPrimaryColor,
              height: kResetPasswordSubmitHeight,
              onPressed: _submit,
              buttonText: "Reset Password",
              buttonTextColor: kWhiteColor,
            ),
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
        const SizedBox(height: kSP10x),
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
