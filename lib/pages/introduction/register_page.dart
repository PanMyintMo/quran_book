import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final repeatPassword = _repeatPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    if (password != repeatPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    try {
      context.showLoadingDialog();
      final userCredential = await _firebaseModel.register(email, password);
      final user = userCredential.user;
      if (user != null) {
        final userId = user.uid;
        await _firebaseModel.createUser(
          UserVO(
            id: userId,
            name: name,
            email: email,
            password: password,
            isAdmin: false,
            isDeleteAccount: false,
            createAt: DateTime.now(),
            updateAt: DateTime.now(),
          ),
        );
        if (mounted) {
          context.hideLoadingDialog();
          context.showSuccessSnackBar("Registration successful");
          context.navigateToNextPageWithRemoveUntil(const LoginPage());
        }
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        _showMessage("Registration failed: ${e.toString()}");
      }
    }
  }

  void _showMessage(String message) {
    context.showErrorSnackBar(message);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
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
              _buildTextField(kRegisterNameTitleText.tr(), kRegisterNameHintText.tr(), _nameController),
              SizedBox(height: kSP20x),
              _buildTextField(kRegisterEmailTitleText.tr(), kRegisterEmailHintText.tr(), _emailController),
              SizedBox(height: kSP20x),
              _buildPasswordField(
                kRegisterPasswordTitleText.tr(),
                kRegisterPasswordHintText.tr(),
                _passwordController,
                _isPasswordVisible,
                () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              SizedBox(height: kSP20x),
              _buildPasswordField(
                kRegisterRepeatPasswordTitleText.tr(),
                kRegisterRepeatPasswordHintText.tr(),
                _repeatPasswordController,
                _isRepeatPasswordVisible,
                () {
                  setState(() => _isRepeatPasswordVisible = !_isRepeatPasswordVisible);
                },
              ),
              SizedBox(height: kSP20x),
              PrimaryButtonWidget(
                width: double.infinity,
                height: kLoginPageButtonHeight,
                backgroundColor: kAppPrimaryColor,
                onPressed: _handleRegister,
                buttonTextColor: kWhiteColor,
                buttonText: kRegister.tr(),
              ),
              // SizedBox(height: kSP20x),
              // Row(
              //   children: [
              //     const Expanded(child: Divider()),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: kSP10x),
              //       child: EasyTextWidget(text: kRegisterContinueWithText.tr()),
              //     ),
              //     const Expanded(child: Divider()),
              //   ],
              // ),
              // SizedBox(height: kSP20x),
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
              SizedBox(height: kSP20x),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EasyTextWidget(text: kRegisterAlreadyAccountText.tr()),
                  TextButton(
                    onPressed: () {
                      context.navigateToNextPageWithReplacement(const LoginPage());
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

  Widget _buildTextField(String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: kSP10x),
        TextField(
          controller: controller,
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

  Widget _buildPasswordField(
    String label,
    String hintText,
    TextEditingController controller,
    bool isVisible,
    VoidCallback toggleVisibility,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: kSP10x),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kSP10x),
            ),
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
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
