import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_and_theme_bloc.dart';
import 'package:quran_book/pages/help_support_page.dart';
import 'package:quran_book/pages/main_page/about_us_page.dart';
import 'package:quran_book/pages/main_page/contact_us_page.dart';
import 'package:quran_book/pages/main_page/language_page.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/utils/get_package_info_utils.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LocalAndThemeBloc>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: EasyTextWidget(
          text:    kDrawerSettingText.tr(),
           textColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black, 
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// 🔹 Theme Switch
          /// bool? means:
          /// - null => System mode selected
          /// - false => Light mode selected
          /// - true => Dark mode selected
          Selector<LocalAndThemeBloc, bool?>(
            selector: (_, bloc) => bloc.isSystemMode ? null : bloc.isDarkMode,
            builder: (context, isDarkMode, _) {
              return Padding(
                padding: const EdgeInsets.all(kSP10x),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(kSP10x),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildThemeOption(
                        context,
                        label: kLightModeText.tr(),
                        value: false,
                        groupValue: isDarkMode,
                        onChanged: () => bloc.setDarkMode(false),
                      ),
                      _buildThemeOption(
                        context,
                        label: kDarkModeText.tr(),
                        value: true,
                        groupValue: isDarkMode,
                        onChanged: () => bloc.setDarkMode(true),
                      ),

                       _buildThemeOption(
                        context,
                        label: "System",
                        value: null,
                        groupValue: isDarkMode,
                        onChanged: () => bloc.setSystemMode(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: kSP20x),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSettingItem(context,  Icons.language, kDrawerLanguageText.tr(),onPress: () {
                  context.navigateToNextPage(LanguagePage());
                  
                },),
                const SizedBox(height: kSP20x),
                _buildSettingItem(context, Icons.star, kDrawerWriteAnAppStoreReviewText.tr(),onPress: () {
                  
                },),
                _buildSettingItem(context, Icons.share, kDrawerShareTheAppText.tr(),onPress: () {
                  
                },),
                const SizedBox(height: kSP20x),
                _buildSettingItem(context, Icons.info, kDrawerAboutUsText.tr(),onPress: () {
                  context.navigateToNextPage(AboutUsPage());
                  
                },),
                _buildSettingItem(context, Icons.phone, kDrawerContactUsText.tr(),onPress: () {
                  context.navigateToNextPage(const ContactUsPage());
                },),
                _buildSettingItem(context, Icons.help, kDrawerHelpAndSupportText.tr(),onPress: () {

                  context.navigateToNextPage(HelpSupportPage());
                  
                },),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: kSP20x),
            child: FutureBuilder<String>(
              future: GetPackageInfoUtils.getAppVersion(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return EasyTextWidget(
                  text: "Version: ${snapshot.data}",
                  textColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // Theme Option
  // -------------------------
  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required bool? value,
    required bool? groupValue,
    required VoidCallback onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    // Use white for dark mode, primary color for light mode
    final radioColor = isDarkMode ? Colors.white : theme.colorScheme.primary;
    
    return Column(
      children: [
        Radio<bool?>(
          value: value,
          groupValue: groupValue,
          onChanged: (_) => onChanged(),
          activeColor: radioColor,
        ),
        Text(label, style: TextStyle(fontSize: kFontSize16x, color: textColor)),
      ],
    );
  }

  // -------------------------
  // Setting Item
  // -------------------------
Widget _buildSettingItem(
  BuildContext context,
  IconData icon,
  String title, {
  required VoidCallback onPress,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: kSP10x,
      vertical: 6,
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800 // 🌙 Dark mode
              : const Color(0xFF3A357C), // ☀️ Light mode (purple like UI)
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: kFontSize16x,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
}

}


