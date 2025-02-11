import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Setting"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
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
                  _buildThemeOption(kLightModeText, false),
                  _buildThemeOption(kDarkModeText, true),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: kSP20x,
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSettingItem(Icons.language, kDrawerLanguageText),
                _buildSettingItem(Icons.notifications, kDrawerNotificationText),
                const SizedBox(
                  height: kSP20x,
                ),
                _buildSettingItem(Icons.star, kDrawerWriteAnAppStoreReviewText),
                _buildSettingItem(Icons.share, kDrawerShareTheAppText),
                const SizedBox(
                  height: kSP20x,
                ),
                _buildSettingItem(Icons.info, kDrawerAboutUsText),
                _buildSettingItem(Icons.contact_mail, kDrawerContactUsText),
                _buildSettingItem(Icons.help, kDrawerHelpAndSupportText),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kSP20x),
            child: Text("Version 1.1", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String text, bool isSelected) {
    return Column(
      children: [
        Radio(
          value: text,
          groupValue: isSelected ? text : null,
          onChanged: (value) {},
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
