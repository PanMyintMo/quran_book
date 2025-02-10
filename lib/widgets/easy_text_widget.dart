import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';

class EasyTextWidget extends StatelessWidget {
  const EasyTextWidget({
    super.key,
    required this.text,
    this.textColor = kBlackColor,
    this.fontSize = kFontSize14x,
    this.fontFamily,
    this.textAlign,
    this.fontWeight,
    this.maxLines,
  });

  final String text;
  final Color textColor;
  final double fontSize;
  final String? fontFamily;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        color: textColor,
        fontSize: fontSize,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
