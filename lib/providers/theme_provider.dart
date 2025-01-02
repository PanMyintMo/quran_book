import 'package:flutter/material.dart';
import 'package:quran_book/local_db/sharepreference.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkModeChecked = true;

  void updateMode({required bool darkMode}) async {
    isDarkModeChecked = darkMode;
    await Sharepreference.setThemeMode("isDarkModeChecked", darkMode);
    notifyListeners();
  }

  Future<void> loadMode() async {
    isDarkModeChecked = await Sharepreference.getThemeMode("isDarkModeChecked") ?? true;
    notifyListeners();
  }
}
