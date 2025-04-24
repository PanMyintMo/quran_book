import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/pages/admin/admin_home_page.dart';
import 'package:quran_book/pages/introduction/forget_password_page.dart';
import 'package:quran_book/pages/introduction/register_page.dart';
import 'package:quran_book/pages/introduction/welcome_page.dart';
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

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    try {
      context.showLoadingDialog();
      await _firebaseModel.login(email, password);
      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar('Login Successful');
        final user = await _firebaseModel.getCurrentUserVO();
        if (user != null && mounted) {
          if (user.isAdmin) {
            context.navigateToNextPageWithRemoveUntil(const AdminHomePage());
          } else {
            context.navigateToNextPageWithRemoveUntil(const IndexPage());
          }
        } else {
          if (mounted) {
            context.navigateToNextPageWithRemoveUntil(const WelcomePage());
          }
        }
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar(e.toString());
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
                    context.navigateToNextPage(const ForgotPasswordPage());
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
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSP10x),
                    child: EasyTextWidget(
                      text: kLoginOrLoginWithText.tr(),
                    ),
                  ),
                  const Expanded(child: Divider()),
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

  Widget _buildSocialLoginButton(String label, String assetPath) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kWhiteColor,
        side: const BorderSide(color: kBlackColor),
        minimumSize: const Size(kGoogleAppleButtonWidth, kGoogleAppleButtonHeight),
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
