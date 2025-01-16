import 'package:flutter/material.dart';

Text appTextField( {required String text, required Color textColor}) {
  return Text(
    text,
    style: TextStyle(color: textColor,fontWeight: FontWeight.w600,fontSize: 14.0,fontFamily:'Poppins' ),
  );
}
