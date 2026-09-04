import 'package:flutter/material.dart';
import 'package:quran_book/resources/dimens.dart';

class EasyTextWidget extends StatelessWidget {
  const EasyTextWidget({
    super.key,
    required this.text,
    this.textColor, // make optional
    this.fontSize = kFontSize14x,
    this.fontFamily,
    this.textAlign,
    this.fontWeight,
    this.maxLines,
  });

  final String text;
  final Color? textColor; // optional
  final double fontSize;
  final String? fontFamily;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    // Use provided color if not null, otherwise use theme
    final color = textColor ?? Theme.of(context).textTheme.bodyMedium?.color ?? Theme.of(context).colorScheme.onSurface;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: fontWeight,
        fontFamily: fontFamily,
        color: color,
        fontSize: fontSize,
      ),
    );
  }
}
