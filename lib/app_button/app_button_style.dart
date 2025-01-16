import 'package:flutter/material.dart';
import 'package:quran_book/app_colors/app_colors.dart';

MaterialButton appbutton(
  BuildContext context,
  VoidCallback onPressed, {
  required String btnText,
}) {
  return MaterialButton(
    minWidth: double.infinity,
    height: 50,
    color: AppColors.btnBackgroundColor,
    textColor: AppColors.whiteColor,
    onPressed: onPressed,
    child: Text(btnText),
  );
}