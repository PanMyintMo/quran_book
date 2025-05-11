import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_and_theme_bloc.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/get_package_info_utils.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: EasyTextWidget(
          text: kDrawerSettingText.tr(),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Selector<LocalAndThemeBloc, bool>(
              selector: (_, bloc) => bloc.isDarkMode,
              builder: (context, isDarkMode, _) {
                return Padding(
                  padding: const EdgeInsets.all(kSP10x),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(kSP10x),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildThemeOption(kLightModeText.tr(), !isDarkMode, context),
                        _buildThemeOption(kDarkModeText.tr(), isDarkMode, context),
                      ],
                    ),
                  ),
                );
              }),
          const SizedBox(
            height: kSP20x,
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSettingItem(
                  Icons.language,
                  kDrawerLanguageText.tr(),
                ),
                //  _buildSettingItem(Icons.notifications, kDrawerNotificationText.tr()),
                const SizedBox(
                  height: kSP20x,
                ),
                _buildSettingItem(Icons.star, kDrawerWriteAnAppStoreReviewText.tr()),
                _buildSettingItem(Icons.share, kDrawerShareTheAppText.tr()),
                const SizedBox(
                  height: kSP20x,
                ),
                _buildSettingItem(Icons.info, kDrawerAboutUsText.tr()),
                _buildSettingItem(Icons.contact_mail, kDrawerContactUsText.tr()),
                _buildSettingItem(Icons.help, kDrawerHelpAndSupportText.tr()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kSP20x),
            child: FutureBuilder<String>(
                future: GetPackageInfoUtils.getAppVersion(),
                builder: (_, snapShot) {
                  if (snapShot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapShot.hasError) {
                    return Center(child: EasyTextWidget(text: snapShot.error.toString()));
                  }
                  return EasyTextWidget(text: "Version: ${snapShot.data.toString()}", textColor: Colors.black54);
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String text, bool isSelected, BuildContext context) {
    return Column(
      children: [
        Radio(
          value: text,
          groupValue: isSelected ? text : null,
          onChanged: (value) {
            // final bloc = context.read<LocalAndThemeBloc>();
            // bloc.toggleTheme();
          },
        ),
        Text(text, style: TextStyle(fontSize: kFontSize16x)),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSP10x, vertical: kSP10x),
      child: Container(
        decoration: BoxDecoration(
          color: kAppPrimaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: TextStyle(color: Colors.white)),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap: () {},
        ),
      ),
    );
  }
}
