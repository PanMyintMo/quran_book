import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/main_page/home_page.dart';
import 'package:quran_book/pages/main_page/profile_page.dart';
import 'package:quran_book/resources/colors.dart';
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
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(),
          BookMarkPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          return BottomNavigationBar(
            unselectedItemColor: Colors.grey,
            currentIndex: _index,
            selectedItemColor: kAppPrimaryColor,
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
                label: kHomePageText.tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                activeIcon: Icon(Icons.bookmark),
                label: kBookmarkText.tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                activeIcon: Icon(Icons.person),
                label: kProfileText.tr(),
              ),
            ],
          );
        },
      ),
    );
  }
}
