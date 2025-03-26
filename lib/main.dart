import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_and_theme_bloc.dart';
import 'package:quran_book/pages/introduction/splash_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp();
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', ''),
        Locale('my', ''),
        Locale('ar', 'SA'),
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en', ''),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<LocalAndThemeBloc>(create: (context) => LocalAndThemeBloc()),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalAndThemeBloc>(builder: (context, bloc, _) {
      return MaterialApp(
        locale: bloc.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        debugShowCheckedModeBanner: false,
        themeMode: bloc.currentThemeMode,
        darkTheme: ThemeData(
          fontFamily: kInter,
          brightness: Brightness.dark,
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.grey[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
              selectedItemColor: kWhiteColor,
              unselectedItemColor: Colors.white70,
              selectedIconTheme: IconThemeData(
                color: kWhiteColor,
              ),
              selectedLabelStyle: TextStyle(
                color: kWhiteColor,
              )),
          iconTheme: IconThemeData(color: Colors.white),
          dividerColor: Colors.white24,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.blue,
            textTheme: ButtonTextTheme.primary,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white70),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
        builder: (context, child) {
          return Directionality(
            textDirection: ui.TextDirection.ltr,
            child: child!,
          );
        },
        home: SplashPage(),
      );
    });
  }
}
