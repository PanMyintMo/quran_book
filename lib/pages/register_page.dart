import 'package:flutter/material.dart';
import 'package:quran_book/app_button/app_button_style.dart';
import 'package:quran_book/app_colors/app_colors.dart';
import 'package:quran_book/app_decoration/app_rich_text.dart';
import 'package:quran_book/app_decoration/app_text_field.dart';
import 'package:quran_book/app_decoration/app_text_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // final GlobalKey<FormState> _formKey = GlobalKey();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              SizedBox(
                height: 50,
              ),
              Container(
                height: 200,
                margin: EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  spacing: 20,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/images/q.png",
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      'Create Your Account',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor),
                    )
                  ],
                ),
              ),
              appTextField(textColor: AppColors.textColor, text: 'Name'),
              appTextFormField(
                controller: nameController,
                labelText: "Enter Your Name",
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              appTextField(textColor: AppColors.textColor, text: 'Email'),
              appTextFormField(
                controller: emailController,
                labelText: "Enter Your Email Address",
                validator: (value) =>
                    value!.isEmpty ? 'Address is required' : null,
              ),
              appTextField(textColor: AppColors.textColor, text: 'Password'),
              appTextFormField(
                controller: passwordController,
                labelText: "Enter Your Password",
                obsText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Password is required' : null,
              ),
              appTextField(
                  textColor: AppColors.textColor, text: 'Confirm Password'),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Repeat Password',
                ),
              ),
              SizedBox(height: 20),
              appbutton(context, () async {}, btnText: 'Login'),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Or continue with",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Google Button
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      "assets/icons/google.png",
                      fit: BoxFit.contain,
                      height: 20,
                    ),
                    label: const Text(
                      "Google",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                    ),
                  ),

                  // Apple Button
                  OutlinedButton.icon(
                    onPressed: () {
                      // Add Apple sign-in functionality
                    },
                    icon: const Icon(
                      Icons.apple,
                      size: 20,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "Apple",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                    ),
                  ),
                ],
              ),
            
              Center(
                child: appRichText(
                  text: TextSpan(
                    text: "Already have an account?  ",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    children: [
                   
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
