import 'dart:ui' as ui;

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_and_theme_bloc.dart';
import 'package:quran_book/firebase_options.dart';
import 'package:quran_book/pages/introduction/new_password_page.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/introduction/splash_page.dart';
import 'package:quran_book/resources/app_theme.dart';
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

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );
  } catch (_) {
    // App Check can fail on some networks/devices; continue without blocking app startup.
  }


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
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
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
