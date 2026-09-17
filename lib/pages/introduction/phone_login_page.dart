import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/pages/admin/admin_home_page.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/pages/main_page/index_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool _otpSent = false;
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _normalizePhone(String raw) {
    var value = raw.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (value.startsWith('00')) {
      value = '+${value.substring(2)}';
    } else if (value.startsWith('0')) {
      value = '+95${value.substring(1)}';
    } else if (!value.startsWith('+')) {
      value = '+95$value';
    }
    return value;
  }

  String _mapPhoneError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'Invalid phone number. Use format +959XXXXXXXXX';
        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again.';
        case 'session-expired':
          return 'OTP expired. Please request a new code.';
        case 'invalid-verification-code':
          return 'Invalid OTP code. Please try again.';
        default:
          return error.message ?? 'Phone login failed. Please try again.';
      }
    }
    return 'Phone login failed. Please try again.';
  }

  Future<void> _sendOtp() async {
    final phone = _normalizePhone(_phoneController.text);
    if (phone.length < 10) {
      context.showErrorSnackBar('Please enter a valid phone number');
      return;
    }

    setState(() => _isSending = true);
    try {
      final session = await _firebaseModel.startPhoneVerification(phone);
      if (!mounted) return;

      if (session.autoCredential != null) {
        await _firebaseModel.signInWithPhoneCredential(session.autoCredential!);
        await _finishSignIn(phone);
        return;
      }

      setState(() {
        _otpSent = true;
        _verificationId = session.verificationId;
      });
      context.showSuccessSnackBar('OTP sent to $phone');
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(_mapPhoneError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    final verificationId = _verificationId;
    if (verificationId == null || code.length < 6) {
      context.showErrorSnackBar('Enter the 6-digit OTP code');
      return;
    }

    try {
      context.showLoadingDialog();
      await _firebaseModel.completePhoneSignIn(
        verificationId: verificationId,
        smsCode: code,
      );
      await _finishSignIn(_normalizePhone(_phoneController.text));
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(_mapPhoneError(e));
      }
    } finally {
      if (mounted) {
        context.hideLoadingDialog();
      }
    }
  }

  Future<void> _finishSignIn(String phone) async {
    final existing = await _firebaseModel.getCurrentUserVO();
    if (existing == null) {
      final uid = await _firebaseModel.resolveAuthUserId();
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : phone;
      await _firebaseModel.tryCreateUser(
        UserVO(
          id: uid,
          name: name,
          email: '${phone.replaceAll('+', '')}@phone.quranbook.app',
          password: '',
          isAdmin: false,
          isDeleteAccount: false,
          createAt: DateTime.now(),
          updateAt: DateTime.now(),
        ),
      );
    }

    unawaited(_firebaseModel.refreshHomeContent());
    if (!mounted) return;

    final user = await _firebaseModel.getCurrentUserVO();
    context.showSuccessSnackBar('Login successful');

    if (user?.isAdmin == true) {
      context.navigateToNextPageWithRemoveUntil(const AdminHomePage());
    } else {
      context.navigateToNextPageWithRemoveUntil(const IndexPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: EasyTextWidget(
          text: kPhoneLoginTitle.tr(),
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kSP20x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.phone_android,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: kSP20x),
            EasyTextWidget(
              text: kPhoneLoginSubText.tr(),
              textAlign: TextAlign.center,
              textColor: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(height: kSP20x),
            if (!_otpSent) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: EasyTextWidget(
                  text: kPhoneLoginNameText.tr(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: kSP10x),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: kPhoneLoginNameHint.tr(),
                ),
              ),
              const SizedBox(height: kSP20x),
              Align(
                alignment: Alignment.centerLeft,
                child: EasyTextWidget(
                  text: kPhoneLoginPhoneText.tr(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: kSP10x),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: kPhoneLoginPhoneHint.tr(),
                  prefixText: '+95 ',
                ),
              ),
              const SizedBox(height: kSP20x),
              PrimaryButtonWidget(
                width: double.infinity,
                height: kLoginPageButtonHeight,
                onPressed: () {
                  if (!_isSending) unawaited(_sendOtp());
                },
                buttonText: _isSending ? kPhoneLoginSending.tr() : kPhoneLoginSendOtp.tr(),
                buttonTextColor: kWhiteColor,
                backgroundColor: kAppPrimaryColor,
              ),
            ] else ...[
              EasyTextWidget(
                text: '${kPhoneLoginOtpSentTo.tr()} ${_normalizePhone(_phoneController.text)}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSP20x),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: kPhoneLoginOtpHint.tr(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: kSP20x),
              PrimaryButtonWidget(
                width: double.infinity,
                height: kLoginPageButtonHeight,
                onPressed: _verifyOtp,
                buttonText: kPhoneLoginVerify.tr(),
                buttonTextColor: kWhiteColor,
                backgroundColor: kAppPrimaryColor,
              ),
              const SizedBox(height: kSP10x),
              TextButton(
                onPressed: _isSending
                    ? null
                    : () {
                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        });
                      },
                child: Text(kPhoneLoginChangeNumber.tr()),
              ),
              TextButton(
                onPressed: _isSending ? null : _sendOtp,
                child: Text(kPhoneLoginResendOtp.tr()),
              ),
            ],
            const SizedBox(height: kSP20x),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EasyTextWidget(
                  text: kPhoneLoginUseEmail.tr(),
                  textColor: theme.textTheme.bodySmall?.color,
                ),
                TextButton(
                  onPressed: () {
                    context.navigateToNextPageWithReplacement(const LoginPage());
                  },
                  child: Text(kLogin.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
