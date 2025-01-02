import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/local_db/sharepreference.dart';
import 'package:quran_book/providers/theme_provider.dart';
import 'package:quran_book/widgets/main_screen/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sharepreference.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadMode(), 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeProvider.isDarkModeChecked
              ? ThemeData.dark(useMaterial3: true)
              : ThemeData.light(useMaterial3: true),
          home: const MainScreen(),
        );
      },
    );
  }
}
