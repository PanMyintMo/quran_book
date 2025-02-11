import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const EasyTextWidget(
          text: kProfileText,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
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
                    text: 'T',
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSize40x,
                    textColor: kWhiteColor,
                  ),
                ),
              ),
              const SizedBox(
                height: kSP20x,
              ),
              EasyTextWidget(
                text: 'Name: Thiha Thant Sin',
                fontSize: kFontSize21x,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: kSP20x,
              ),
              EasyTextWidget(
                text: 'Email: thantsin7755@gmail.com',
                fontSize: kFontSize21x,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: kSP40x,
              ),
              PrimaryButtonWidget(
                height: kProfilePageButtonHeight,
                width: double.infinity,
                onPressed: () {},
                buttonText: kDeleteAccountText,
                backgroundColor: Colors.amber,
                buttonFontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: kSP10x,
              ),
              PrimaryButtonWidget(
                height: kProfilePageButtonHeight,
                width: double.infinity,
                onPressed: () {},
                buttonText: kLogoutText,
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
