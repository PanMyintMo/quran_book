import 'package:flutter/material.dart';
import 'package:quran_book/app_button/app_button_style.dart';
import 'package:quran_book/app_colors/app_colors.dart';
import 'package:quran_book/app_decoration/app_rich_text.dart';
import 'package:quran_book/app_decoration/app_text_field.dart';
import 'package:quran_book/app_decoration/app_text_form_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
   final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
                      'Welcome to our page',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor),
                    )
                  ],
                ),
              ),
            
            appTextField(textColor: AppColors.textColor, text: 'Email Address'),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: (){}, child: Text('Forget Your Password?',style: TextStyle(color: AppColors.textColor),))),
                appbutton(context, () async {}, btnText: 'Login'),

    Center(
                child: appRichText(
                  text: TextSpan(
                    text: "Don't ?  ",
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
