import 'dart:ui' as ui;

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_and_theme_bloc.dart';
import 'package:quran_book/firebase_options.dart';
import 'package:quran_book/pages/introduction/new_password_page.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/introduction/splash_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/strings.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

 // await Firebase.initializeApp();
 await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );


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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Handle link when app is already open
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // Handle link when app is launched cold via a link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    final mode = uri.queryParameters['mode'];
    final oobCode = uri.queryParameters['oobCode'];

    if (mode == 'resetPassword' && oobCode != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => NewPasswordPage(oobCode: oobCode),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalAndThemeBloc>(builder: (context, bloc, _) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [BookMarkRouteObserver.instance],
        locale: bloc.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        debugShowCheckedModeBanner: false,
        themeMode: bloc.currentThemeMode,
        theme: ThemeData(
          fontFamily: kInter,
          brightness: Brightness.light,
          primaryColor: kAppPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: kAppPrimaryColor,
            unselectedItemColor: Colors.grey,
            selectedIconTheme: IconThemeData(
              color: kAppPrimaryColor,
            ),
            unselectedIconTheme: IconThemeData(
              color: Colors.grey,
            ),
            selectedLabelStyle: TextStyle(
              color: kAppPrimaryColor,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          dividerColor: Colors.black12,
          buttonTheme: ButtonThemeData(
            buttonColor: kAppPrimaryColor,
            textTheme: ButtonTextTheme.primary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppPrimaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kAppPrimaryColor),
            ),
            labelStyle: TextStyle(color: Colors.black87),
            hintStyle: TextStyle(color: Colors.grey),
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
            bodyLarge: TextStyle(color: Colors.black),
            bodySmall: TextStyle(color: Colors.black54),
          ),
          colorScheme: ColorScheme.light(
            primary: kAppPrimaryColor,
            secondary: kAppPrimaryColor,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        darkTheme: ThemeData(
          fontFamily: kInter,
          brightness: Brightness.dark,
          primaryColor: kAppPrimaryColor,
          scaffoldBackgroundColor: Color(0xFF121212),
          cardColor: Color(0xFF1E1E1E),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF121212),
            // Keep labels in your primary color, but
            // make the selected icon pure white for stronger contrast.
            selectedItemColor: kAppPrimaryColor,
            unselectedItemColor: Colors.white70,
            selectedIconTheme: const IconThemeData(
              color: Colors.white,
            ),
            unselectedIconTheme: const IconThemeData(
              color: Colors.white70,
            ),
            selectedLabelStyle: const TextStyle(
              color: kAppPrimaryColor,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          dividerColor: Colors.white24,
          buttonTheme: ButtonThemeData(
            buttonColor: kAppPrimaryColor,
            textTheme: ButtonTextTheme.primary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppPrimaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF2C2C2C),
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
              borderSide: BorderSide(color: kAppPrimaryColor),
            ),
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white70),
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white70),
          ),
          colorScheme: ColorScheme.dark(
            primary: kAppPrimaryColor,
            secondary: kAppPrimaryColor,
            surface: Color(0xFF1E1E1E),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
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
