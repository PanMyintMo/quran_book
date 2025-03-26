import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_and_theme_bloc.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = "";

  @override
  void initState() {
    final bloc = context.read<LocalAndThemeBloc>();
    selectedLanguage = bloc.getLanguageByLocale;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: EasyTextWidget(
          text: kDrawerLanguageText.tr(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSP20x),
        child: Column(
          children: [
            _buildLanguageOption(AssetImageUtils.kEnFlag, "English"),
            SizedBox(height: 16),
            _buildLanguageOption(AssetImageUtils.kMMFlag, "Myanmar"),
            SizedBox(height: 16),
            _buildLanguageOption(AssetImageUtils.kSAFlag, "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flagPath, String language) {
    bool isSelected = selectedLanguage == language;
    return Container(
      padding: EdgeInsets.symmetric(vertical: kSP10x),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? kAppPrimaryColor : kBlackColor),
        borderRadius: BorderRadius.circular(kSP10x),
        color: isSelected ? kAppPrimaryColor.withOpacity(0.1) : kWhiteColor,
      ),
      child: ListTile(
        leading: Image.asset(flagPath, width: kSP40x, height: kSP40x),
        title: Text(language, textAlign: TextAlign.center),
        trailing: isSelected ? Icon(Icons.check, color: kAppPrimaryColor) : null,
        onTap: () {
          if (mounted) {
            setState(() {
              selectedLanguage = language;
              // final bloc = context.read<LocalAndThemeBloc>();
              // bloc.setLocaleWithLanguage(selectedLanguage, context);
            });
          }
        },
      ),
    );
  }
}
