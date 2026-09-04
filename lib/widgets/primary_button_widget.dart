import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final Function onPressed;
  final Color? backgroundColor;
  final String buttonText;
  final Color? buttonTextColor;
  final double? radius;
  final Color? borderColor;
  final FontWeight? buttonFontWeight;

  const PrimaryButtonWidget({
    super.key,
    required this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    required this.buttonText,
    this.buttonTextColor,
    this.radius,
    this.buttonFontWeight,
  }) : borderColor = Colors.transparent;

  const PrimaryButtonWidget.ghostButton({
    super.key,
    required this.onPressed,
    this.width,
    this.height,
    required this.buttonText,
    this.buttonTextColor,
    this.radius,
    this.borderColor,
    this.buttonFontWeight,
  }) : backgroundColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius ?? 0),
        side: BorderSide(
          color: borderColor ?? kWhiteColor,
        ),
      ),
      minWidth: width,
      height: height,
      onPressed: () => onPressed(),
      color: backgroundColor,
      child: EasyTextWidget(
        text: buttonText,
        textColor: buttonTextColor ?? onSurface,
        fontWeight: buttonFontWeight,
      ),
    );
  }
}
