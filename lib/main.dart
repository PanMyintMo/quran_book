import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/providers/theme_provider.dart';
import 'package:quran_book/widgets/main_screen/main_screen.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) =>
       ThemeProvider(),


    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
   Provider.of<ThemeProvider>(context,listen: false).loadMode(); 
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeProvider.isDarkModeChecked ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
       home: MainScreen(),    
    );
  }
}

