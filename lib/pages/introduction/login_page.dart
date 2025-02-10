import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/register_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Image.asset(AssetImageUtils.kAppIcon, height: 80),
              SizedBox(height: 16),
              Text(
                "Welcome to our page",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Enter your username and password to continue.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your email address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 8),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: Icon(Icons.visibility_off),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot your password? Reset now",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppPrimaryColor,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {},
                child: Text("Login", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Or Login with"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialLoginButton(
                    "Google",
                    AssetImageUtils.kGoogleIcon,
                  ),
                  SizedBox(width: 16),
                  _buildSocialLoginButton(
                    "Apple",
                    AssetImageUtils.kAppleIcon,
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      context.navigateToNextPageWithReplacement(RegisterPage());
                    },
                    child: Text("Register", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton(String label, String assetPath) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.black),
        minimumSize: Size(150, 50),
      ),
      onPressed: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, height: 24),
          SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
