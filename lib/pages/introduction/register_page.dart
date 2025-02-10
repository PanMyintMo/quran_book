import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                "Create Your Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Enter your username and password to continue",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              _buildTextField("Name", "Enter your name"),
              SizedBox(height: 16),
              _buildTextField("Email Address", "Enter your email address"),
              SizedBox(height: 16),
              _buildPasswordField("Password", "Enter your password"),
              SizedBox(height: 16),
              _buildPasswordField("Repeat Password", "Enter your password"),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
                    child: Text("Or continue with"),
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
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      context.navigateToNextPageWithReplacement(LoginPage());
                    },
                    child: Text("Sign up", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
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
