import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/reset_password_page.dart';
import 'package:quran_book/utils/context_extensions.dart';

class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Icon(Icons.email, size: 80, color: Colors.black),
            SizedBox(height: 16),
            Text(
              "Check your email",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We've sent you a password reset link. Please check your email.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                context.navigateToNextPage(ResetPasswordPage());
              },
              child: Text("Reset Password", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: Text("Open email", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text("Didn't receive the email? Resend"),
            ),
          ],
        ),
      ),
    );
  }
}
