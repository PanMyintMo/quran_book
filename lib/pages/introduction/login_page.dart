import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/pages/admin/admin_home_page.dart';
// import 'package:quran_book/pages/introduction/forget_password_page.dart';
import 'package:quran_book/pages/introduction/register_page.dart';
import 'package:quran_book/pages/introduction/reset_password_page.dart';
import 'package:quran_book/pages/main_page/index_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  String _mapLoginErrorToMessage(Object error) {
    final raw = error.toString().toLowerCase();

    // FirebaseModel wraps FirebaseAuthException into an Exception with message,
    // so we match by text/code fragments.
    if (raw.contains('wrong-password') || raw.contains('password is invalid')) {
      return 'Wrong password. Please try again.';
    }
    if (raw.contains('user-not-found') ||
        raw.contains('no user') ||
        raw.contains('there is no user')) {
      return 'Email not found. Please register first.';
    }
    if (raw.contains('invalid-email')) {
      return 'Invalid email address.';
    }
    if (raw.contains('network') ||
        raw.contains('internet') ||
        raw.contains('failed to fetch') ||
        raw.contains('connection')) {
      return 'Network error. Check your internet and try again.';
    }

    // Fallback
    return 'Login failed. Please try again.';
  }

  String _mapFirebaseAuthCodeToMessage(FirebaseAuthException e) {
    final code = e.code;
    final msg = (e.message ?? '').toLowerCase();

    // Be careful with message matching: "does not exist" can appear in other cases.
    final isUserNotFound = code == 'user-not-found' ||
        msg.contains('user-not-found') ||
        msg.contains('no user') ||
        msg.contains('there is no user') ||
        msg.contains('not found');

    final isWrongPassword = code == 'wrong-password' ||
        code == 'invalid-credential' ||
        msg.contains('wrong-password') ||
        msg.contains('password is invalid') ||
        (msg.contains('password') && msg.contains('invalid'));

    // Priority: if Firebase says user not found (wrong email), show email error
    // even if message text also contains the word "password".
    if (isUserNotFound) {
      return 'Email not found. Please register first.';
    }

    if (isWrongPassword) {
      return 'Wrong password. Please try again.';
    }

    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong password. Please try again.';
      case 'user-not-found':
        return 'Email not found. Please register first.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  Future<String> _mapFirebaseAuthExceptionForLogin(
    FirebaseAuthException e,
    String email,
  ) async {
    // Common message for any wrong-credentials case (email or password).
    if (e.code == 'wrong-password' ||
        e.code == 'user-not-found' ||
        e.code == 'invalid-credential') {
      return 'Email or password is incorrect. Please try again.';
    }

    // Specific cases that are NOT just wrong credentials.
    if (e.code == 'invalid-email') {
      return 'Invalid email address.';
    }
    if (e.code == 'too-many-requests') {
      return 'Too many attempts. Please wait and try again.';
    }

    final msg = (e.message ?? '').toLowerCase();
    if (msg.contains('network') ||
        msg.contains('internet') ||
        msg.contains('failed to fetch') ||
        msg.contains('connection')) {
      return 'Network error. Check your internet and try again.';
    }

    return _mapFirebaseAuthCodeToMessage(e);
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      context.showErrorSnackBar('Please enter email and password');
      return;
    }

    try {
      context.showLoadingDialog();
      await _firebaseModel.login(email, password);
      unawaited(_firebaseModel.refreshHomeContent());

      UserVO? user;
      try {
        user = await _firebaseModel.getCurrentUserVO();
      } catch (_) {
        // Auth succeeded — proceed to home even if profile fetch fails.
      }

      if (!context.mounted) return;
      context.showSuccessSnackBar('Login Successful');

      if (user?.isAdmin == true) {
        if (!context.mounted) return;
        context.navigateToNextPageWithRemoveUntil(const AdminHomePage());
      } else {
        if (!context.mounted) return;
        context.navigateToNextPageWithRemoveUntil(const IndexPage());
      }
    } catch (e) {
      if (mounted) {
        if (e is FirebaseAuthException) {
          final message = await _mapFirebaseAuthExceptionForLogin(e, email);
          context.showErrorSnackBar(message);
        } else {
          context.showErrorSnackBar(_mapLoginErrorToMessage(e));
        }
      }
    } finally {
      if (mounted) {
        context.hideLoadingDialog();
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                controller: _emailController,
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
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: kLoginPasswordHintText.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kSP10x),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: kSP10x),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    
                    context.navigateToNextPage(ResetPasswordPage());
                  //  context.navigateToNextPage(const ForgotPasswordPage());
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
                onPressed: _handleLogin,
                buttonText: kLogin.tr(),
                buttonTextColor: kWhiteColor,
                backgroundColor: kAppPrimaryColor,
              ),
              SizedBox(height: kSP10x),
              // Google/Apple login not implemented yet - hidden
              // Row(
              //   children: [
              //     const Expanded(child: Divider()),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: kSP10x),
              //       child: EasyTextWidget(
              //         text: kLoginOrLoginWithText.tr(),
              //       ),
              //     ),
              //     const Expanded(child: Divider()),
              //   ],
              // ),
              // SizedBox(height: kSP10x),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     _buildSocialLoginButton(
              //       kGoogle.tr(),
              //       AssetImageUtils.kGoogleIcon,
              //     ),
              //     SizedBox(width: kSP20x),
              //     _buildSocialLoginButton(
              //       kApple.tr(),
              //       AssetImageUtils.kAppleIcon,
              //     ),
              //   ],
              // ),
              // SizedBox(height: kSP20x),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EasyTextWidget(text: kLoginDoNoHaveAnAccountText.tr(), textColor: isDarkMode ? kWhiteColor : Colors.grey),
                  PrimaryButtonWidget(
                    buttonText: kRegister.tr(),
                    buttonTextColor: isDarkMode ? kWhiteColor : kAppPrimaryColor,
                    buttonFontWeight: FontWeight.bold,
                    onPressed: () {
                      context.navigateToNextPageWithReplacement(const RegisterPage());
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

  // Google/Apple login not implemented - keeping for future use
  // Widget _buildSocialLoginButton(String label, String assetPath) {
  //   return ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: kWhiteColor,
  //       side: const BorderSide(color: kBlackColor),
  //       minimumSize: const Size(kGoogleAppleButtonWidth, kGoogleAppleButtonHeight),
  //     ),
  //     onPressed: () {},
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Image.asset(assetPath, height: kGoogleAppleImageHeight),
  //         SizedBox(width: kSP10x),
  //         EasyTextWidget(
  //           text: label,
  //           textColor: kBlackColor,
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
