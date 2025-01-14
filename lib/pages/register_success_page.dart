import 'package:flutter/material.dart';
import 'package:quran_book/pages/on_boarding_page.dart';
import 'package:quran_book/utils/context_extensions.dart';

class RegisterSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.yellow[700],
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Account Created Successfully',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.navigateToNextPageWithRemoveUntil(OnBoardingPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
              ),
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
