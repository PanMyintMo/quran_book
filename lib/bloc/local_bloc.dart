import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalBloc extends ChangeNotifier {
  Locale _locale = Locale('en', '');

  Locale get locale => _locale;

  LocalBloc() {
    _loadSavedLocale();
  }

  Future<void> setLocale(Locale locale, BuildContext context) async {
    _locale = locale;
    context.setLocale(locale);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    notifyListeners();
  }

  Future<void> _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode, '');
    }
    notifyListeners();
  }
}
