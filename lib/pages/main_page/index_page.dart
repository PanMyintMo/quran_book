import 'package:flutter/material.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/main_page/home_page.dart';
import 'package:quran_book/pages/main_page/profile_page.dart';
import 'package:quran_book/resources/colors.dart';

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
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(
              Icons.home_filled,
            ),
            activeIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bookmark_border,
            ),
            activeIcon: Icon(
              Icons.bookmark,
            ),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_2_outlined,
            ),
            activeIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
