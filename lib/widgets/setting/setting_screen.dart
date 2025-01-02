import 'package:flutter/material.dart';
import 'package:quran_book/widgets/setting/theme_switcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"),),
      body: Column(children: [
        ThemeSwitcher()
      ],),
    );
  }
}