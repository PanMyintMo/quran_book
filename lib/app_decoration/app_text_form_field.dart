import 'package:flutter/material.dart';
import 'package:quran_book/app_decoration/decoration.dart';

TextFormField appTextFormField({
  required TextEditingController controller,
  required String labelText,
  TextInputType? keyboardType,
  bool? obsText,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    textInputAction: TextInputAction.next,
    obscureText : obsText ?? false,
    keyboardType: keyboardType,
    decoration: authdecor(labelText: labelText),
    validator: validator,
  );
}