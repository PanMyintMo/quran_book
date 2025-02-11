import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAndThemeBloc extends ChangeNotifier {
  Locale _locale = Locale('en', '');
  bool _isDarkMode = false; // Default to light mode

  Locale get locale => _locale;
  bool get isDarkMode => _isDarkMode;

  LocalAndThemeBloc() {
    _loadSavedPreferences();
  }

  /// Set Locale and Save in SharedPreferences
  Future<void> setLocale(Locale locale, BuildContext context) async {
    _locale = locale;
    context.setLocale(locale);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    notifyListeners();
  }

  /// Set Locale using Language Name
  void setLocaleWithLanguage(String language, BuildContext context) {
    Locale locale;
    if (language == 'English') {
      locale = Locale('en', '');
    } else if (language == 'Myanmar') {
      locale = Locale('my', '');
    } else {
      locale = Locale('ar', 'SA');
    }

    setLocale(locale, context);
  }

  /// Get Language Display Name
  String get getLanguageByLocale {
    if (_locale == Locale('en', '')) {
      return 'English';
    }
    if (_locale == Locale('my', '')) {
      return 'Myanmar';
    }
    return "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";
  }

  /// Load saved Locale and Theme from SharedPreferences
  Future<void> _loadSavedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    bool? savedTheme = prefs.getBool('isDarkMode');

    if (languageCode != null) {
      _locale = Locale(languageCode, '');
    }

    if (savedTheme != null) {
      _isDarkMode = savedTheme;
    }

    notifyListeners();
  }

  /// Toggle Dark Mode and Save in SharedPreferences
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }

  /// Get ThemeMode based on `_isDarkMode`
  ThemeMode get currentThemeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
