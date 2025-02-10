import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

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
            Image.asset(AssetImageUtils.kAppIcon, height: 80),
            SizedBox(height: 16),
            Text(
              "Create a new password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Enter your new password below to complete the reset process.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildPasswordField("New Password", "Enter your password"),
            SizedBox(height: 16),
            _buildPasswordField("Repeat New Password", "Enter your password"),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                context.navigateToNextPageWithRemoveUntil(LoginPage());
              },
              child: Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: Icon(Icons.visibility_off),
          ),
        ),
      ],
    );
  }
}
