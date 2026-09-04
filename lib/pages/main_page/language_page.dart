import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_and_theme_bloc.dart';
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
          textColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSP20x),
        child: Column(
          children: [
            _buildLanguageOption(context, AssetImageUtils.kEnFlag, "English"),
            SizedBox(height: 16),
            _buildLanguageOption(context, AssetImageUtils.kMMFlag, "Myanmar"),
            SizedBox(height: 16),
            _buildLanguageOption(context, AssetImageUtils.kSAFlag, "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String flagPath, String language) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    bool isSelected = selectedLanguage == language;
    
    // Use theme-aware colors
    final borderColor = isSelected 
        ? colorScheme.primary 
        : (isDarkMode ? Colors.grey[700] : Colors.grey[300]);
    final backgroundColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.1)
        : theme.cardColor;
    final checkIconColor = isDarkMode ? Colors.white : colorScheme.primary;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.grey),
        borderRadius: BorderRadius.circular(kSP10x),
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(kSP10x),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (mounted) {
              setState(() {
                selectedLanguage = language;
                final bloc = context.read<LocalAndThemeBloc>();
                bloc.setLocaleWithLanguage(selectedLanguage, context);
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: kSP10x,
              horizontal: kSP10x,
            ),
            child: Row(
              children: [
                Image.asset(flagPath, width: kSP40x, height: kSP40x),
                Expanded(
                  child: Text(
                    language,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color ??
                          colorScheme.onSurface,
                      fontSize: kFontSize16x,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, color: checkIconColor)
                else
                  const SizedBox(width: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
