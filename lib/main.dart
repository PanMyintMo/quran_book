import 'package:flutter/material.dart';
import 'package:quran_book/pages/main_page/index_page.dart';
import 'package:quran_book/resources/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: kInter,
      ),
      home: IndexPage(),
    );
  }
}
