import 'package:flutter/material.dart';
import 'package:quran_book/pages/register_page.dart';
import 'package:quran_book/pages/sign_up_page.dart';
import 'package:quran_book/utils/context_extensions.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

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
              'Starting To Live With The Al-Quran',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.navigateToNextPage(SignUpPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
              ),
              child: Text('Read Direct'),
            ),
            ElevatedButton(
              onPressed: () {
                context.navigateToNextPage(RegisterPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
              ),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
