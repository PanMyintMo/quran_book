import 'package:flutter/material.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final cardColor = theme.cardColor;
    final titleColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: EasyTextWidget(
          text: kDrawerHelpAndSupportText.tr(),
          textColor: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.background.withOpacity(0.9),
              theme.colorScheme.background,
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
                  // Title
                  Text(
                    "Help & Support",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : titleColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    "We’re here to help you.\n\n"
                    "If you have questions, experience any issues, or need support while using the app, please contact us through the available support channels. "
                    "Our team is committed to providing timely assistance and ensuring a smooth experience for all users.\n\n"
                    "Thank you for using our app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 20),

                  // Contact Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Add your email action
                        },
                        icon: const Icon(Icons.email),
                        color: isDark ? Colors.white : theme.colorScheme.primary,
                      ),
                      IconButton(
                        onPressed: () {
                          // Add your phone action
                        },
                        icon: const Icon(Icons.phone),
                        color: isDark ? Colors.white : theme.colorScheme.primary,
                      ),
                      IconButton(
                        onPressed: () {
                          // Add any chat/support link
                        },
                        icon: const Icon(Icons.chat),
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
