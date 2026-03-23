import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/pages/introduction/welcome_page.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  UserVO? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _firebaseModel.getCurrentUserVO();
    setState(() {
      _user = user;
    });
  }

  Future<void> _deleteAccount() async {
    if (_user != null) {
      await _firebaseModel.deleteUser(_user!.id);
      await _firebaseModel.currentUser?.delete();
      await _firebaseModel.logout();
      if (context.mounted) {
        context.navigateToNextPageWithRemoveUntil(const WelcomePage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomePageDrawerView(),
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: EasyTextWidget(
          text: kProfileText.tr(),
          fontWeight: FontWeight.w600,
        ),
      ),
      body: _user == null
          ? Padding(
              padding: const EdgeInsets.all(kSP20x),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 100, color: Colors.grey),
                  const SizedBox(height: kSP20x),
                  Align(
                    alignment: Alignment.centerRight,
                    child: EasyTextWidget(
                      text: 'Guest User',
                      textAlign: TextAlign.right,
                      fontWeight: FontWeight.w600,
                      fontSize: kFontSize21x,
                    ),
                  ),
                  const SizedBox(height: kSP20x),
                  Align(
                    alignment: Alignment.centerRight,
                    child: EasyTextWidget(
                      text: 'You are using the app as a guest.',
                      textAlign: TextAlign.right,
                      fontWeight: FontWeight.w400,
                      fontSize: kFontSize16x,
                    ),
                  ),
                  const SizedBox(height: kSP30x),
                  PrimaryButtonWidget(
                    height: kProfilePageButtonHeight,
                    width: double.infinity,
                    onPressed: () {
                      context.navigateToNextPageWithRemoveUntil(
                        const LoginPage(),
                      );
                    },
                    buttonText: kLogin.tr(),
                    backgroundColor: kAppPrimaryColor,
                    buttonTextColor: kWhiteColor,
                    buttonFontWeight: FontWeight.w600,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(kSP20x),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: kAppPrimaryColor,
                        child: EasyTextWidget(
                          text: _user!.name.substring(0, 1).toUpperCase(),
                          fontWeight: FontWeight.w600,
                          fontSize: kFontSize40x,
                          textColor: kWhiteColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: kSP20x),
                    EasyTextWidget(
                      text: 'Name: ${_user!.name}',
                      fontSize: kFontSize21x,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: kSP20x),
                    EasyTextWidget(
                      text: 'Email: ${_user!.email}',
                      fontSize: kFontSize21x,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: kSP40x),
                    PrimaryButtonWidget(
                      height: kProfilePageButtonHeight,
                      width: double.infinity,
                      onPressed: _deleteAccount,
                      buttonText: kDeleteAccountText.tr(),
                      backgroundColor: Colors.amber,
                      buttonFontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: kSP10x),
                    PrimaryButtonWidget(
                      height: kProfilePageButtonHeight,
                      width: double.infinity,
                      onPressed: () async {
                        context.showLoadingDialog();
                        try {
                          await _firebaseModel.logout();
                          if (context.mounted) {
                            context.hideLoadingDialog();
                            context.showSuccessSnackBar(kLogoutText.tr());
                            context.navigateToNextPageWithRemoveUntil(LoginPage());
                          }
                        } catch (error) {
                          if (context.mounted) {
                            context.hideLoadingDialog();
                            context.showErrorSnackBar(error.toString());
                          }
                        }
                      },
                      buttonText: kLogoutText.tr(),
                      backgroundColor: Colors.red,
                      buttonFontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
