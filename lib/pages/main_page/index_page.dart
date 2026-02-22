import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/main_page/home_page.dart';
import 'package:quran_book/pages/main_page/profile_page.dart';
import 'package:quran_book/resources/strings.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            HomePage(),
            BookMarkPage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final bottomNavTheme = theme.bottomNavigationBarTheme;
          return BottomNavigationBar(
            backgroundColor: bottomNavTheme.backgroundColor,
            unselectedItemColor: bottomNavTheme.unselectedItemColor,
            currentIndex: _index,
            selectedItemColor: bottomNavTheme.selectedItemColor,
            selectedIconTheme: bottomNavTheme.selectedIconTheme,
            unselectedIconTheme: bottomNavTheme.unselectedIconTheme,
            onTap: (index) {
              if (mounted) {
                setState(() {
                  _index = index;
                });
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                activeIcon: Icon(Icons.home),
                label: context.tr(kHomePageText),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                activeIcon: Icon(Icons.bookmark),
                label: context.tr(kBookmarkText),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                activeIcon: Icon(Icons.person),
                label: context.tr(kProfileText),
              ),
            ],
          );
        },
      ),
    );
  }
}
