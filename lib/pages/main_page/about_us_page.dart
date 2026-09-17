import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/phone_login_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final titleColor = theme.colorScheme.onSurface;
    final bodyColor = theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: EasyTextWidget(
          text: kDrawerAboutUsText.tr(),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.background.withOpacity(0.9),
              theme.colorScheme.background
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Card(
            elevation: 4,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            shadowColor: theme.colorScheme.primary.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar or Logo
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: const AssetImage(
                      'assets/images/on_boarding_image.png',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    "Our Company",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Text(
                    "Our App lets you read books, listen to audiobooks, and support meaningful causes through donations. "
                    "Enjoy knowledge and stories anytime, anywhere—whether you prefer reading or listening.\n"
                    "With easy access to content and a simple donation feature, we aim to connect readers, listeners, and supporters in one platform.\n"
                    "Learn, listen, and give back—all in one app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: bodyColor),
                  ),
                  const SizedBox(height: kSP20x),
                  PrimaryButtonWidget(
                    width: double.infinity,
                    height: kLoginPageButtonHeight,
                    onPressed: () {
                      context.navigateToNextPage(const PhoneLoginPage());
                    },
                    buttonText: kPhoneLoginWithPhone.tr(),
                    buttonTextColor: kWhiteColor,
                    backgroundColor: kAppPrimaryColor,
                  ),
                  const SizedBox(height: kSP20x),

                  // Social / Contact Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.facebook),
                        color: isDark ? Colors.white : theme.colorScheme.primary,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.email),
                        color: isDark ? Colors.white : theme.colorScheme.primary,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone),
                        color: isDark ? Colors.white : theme.colorScheme.primary,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
