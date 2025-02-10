import 'dart:math';

import 'package:flutter/material.dart';

class RandomColorUtils {
  static Color getRandomColor() {
    final r = Random().nextInt(256);
    final g = Random().nextInt(256);
    final b = Random().nextInt(256);
    return Color.fromRGBO(r, g, b, 1);
  }
}
