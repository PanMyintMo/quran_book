import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAndThemeBloc extends ChangeNotifier {
  Locale _locale = const Locale('en', '');
  bool _isDarkMode = false; // Default to light mode

  Locale get locale => _locale;
  bool get isDarkMode => _isDarkMode;

  LocalAndThemeBloc() {
    _loadSavedPreferences();
  }

  // -------------------------
  // Locale Methods
  // -------------------------
  Future<void> setLocale(Locale locale, BuildContext context) async {
    _locale = locale;
    context.setLocale(locale);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    notifyListeners();
  }

  void setLocaleWithLanguage(String language, BuildContext context) {
    Locale locale;
    if (language == 'English') {
      locale = const Locale('en', '');
    } else if (language == 'Myanmar') {
      locale = const Locale('my', '');
    } else {
      locale = const Locale('ar', 'SA');
    }

    setLocale(locale, context);
  }

  String get getLanguageByLocale {
    if (_locale == const Locale('en', '')) return 'English';
    if (_locale == const Locale('my', '')) return 'Myanmar';
    return "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";
  }

  // -------------------------
  // Theme Methods
  // -------------------------
  /// Set dark mode and save to SharedPreferences
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }

  /// Toggle theme
  Future<void> toggleTheme() async {
    await setDarkMode(!_isDarkMode);
  }

  ThemeMode get currentThemeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // -------------------------
  // Load saved preferences
  // -------------------------
  Future<void> _loadSavedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load saved language
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode, '');
    }

    // Load saved theme
    bool? savedTheme = prefs.getBool('isDarkMode');
    if (savedTheme != null) {
      _isDarkMode = savedTheme;
    }

    notifyListeners();
  }
}
