import 'package:flutter/material.dart';
import 'package:quran_book/app_colors/app_colors.dart';

InputDecoration authdecor({required dynamic labelText,Widget? suffixIcon}) {
  return InputDecoration(
    labelText: labelText,
    suffixIcon: suffixIcon,
    border: const OutlineInputBorder(),
    focusedBorder:  OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.textColor, width: 1.0),
    ),
  );
}