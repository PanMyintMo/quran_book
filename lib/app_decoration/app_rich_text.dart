import 'package:flutter/material.dart';

RichText appRichText({
  Key? key,
  required TextSpan text,
  TextAlign textAlign = TextAlign.start,
  TextOverflow overflow = TextOverflow.clip,
  int? maxLines,
  TextWidthBasis textWidthBasis = TextWidthBasis.parent,
  TextHeightBehavior? textHeightBehavior,
  Locale? locale,
  bool? softWrap,
}) {
  return RichText(
    key: key,
    text: text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
    locale: locale,
    softWrap: softWrap ?? false,
  );
}
