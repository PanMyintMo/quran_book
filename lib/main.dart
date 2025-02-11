import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_bloc.dart';
import 'package:quran_book/pages/introduction/splash_page.dart';
import 'package:quran_book/resources/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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
          ChangeNotifierProvider<LocalBloc>(create: (context) => LocalBloc()),
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
    return Consumer<LocalBloc>(builder: (context, bloc, _) {
      return MaterialApp(
        locale: bloc.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: kInter,
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
