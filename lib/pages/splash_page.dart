import 'package:flutter/material.dart';
import 'package:quran_book/pages/on_boarding_page.dart';
import 'package:quran_book/utils/context_extensions.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/book.png', height: 150),
            SizedBox(height: 20),
            Text(
              'Welcome to Our Quran',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.navigateToNextPage(OnBoardingPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
              ),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
