import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/reset_password_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({super.key});

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
            Icon(Icons.email, size: kCheckEmailIconSize, color: Theme.of(context).iconTheme.color),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kCheckYourEmailLabelText.tr(),
              fontSize: kFontSize22x,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: kSP10x),
            EasyTextWidget(
              text: kCheckYourEmailSentText.tr(),
              textColor: Colors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kSP10x),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: kSP15x, vertical: kSP10x),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700, size: 18),
                  SizedBox(width: kSP10x),
                  Expanded(
                    child: EasyTextWidget(
                      text: "Can't find the email? Check your spam or junk folder.",
                      textColor: Colors.amber.shade800,
                      fontSize: kFontSize12x,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              backgroundColor: kAppPrimaryColor,
              height: kCheckEmailResetButtonHeight,
              onPressed: () {
                context.navigateToNextPageWithReplacement(ResetPasswordPage());
              },
              buttonText: kCheckYourEmailResendEmailText.tr(),
              buttonTextColor: kWhiteColor,
            ),
            SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              backgroundColor: kAppPrimaryColor,
              height: kCheckEmailResetButtonHeight,
              onPressed: () async {
                final uri = Uri(scheme: 'mailto');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  if (context.mounted) {
                    context.showErrorSnackBar('Could not open email app');
                  }
                }
              },
              buttonText: kCheckYourEmailOpenEmailText.tr(),
              buttonTextColor: kWhiteColor,
            ),
            SizedBox(height: kSP20x),
            PrimaryButtonWidget(
              onPressed: () {},
              buttonText: kCheckYourEmailDidNotGetText.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
