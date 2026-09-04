import 'package:flutter/material.dart';

const kAppPrimaryColor = Color(0xFF191a48);
const kWhiteColor = Colors.white;
const kBlackColor = Colors.black;

const kAppYellowButtonColor = Color(0xFFDDAD45);
const kBoxColor = Color(0xFFD9D9D9);

/// Surface tile/card background that adapts to light/dark theme.
Color adaptiveSurfaceTileColor(BuildContext context) {
  return Theme.of(context).colorScheme.surfaceContainerHighest;
}

/// Border color that adapts to light/dark theme.
Color adaptiveBorderColor(BuildContext context) {
  return Theme.of(context).colorScheme.outline;
}

/// Primary text/icon color that adapts to light/dark theme.
Color adaptiveOnSurfaceColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface;
}

/// Profile screen (reference dark layout)
const kProfileDarkBackground = Color(0xFF1A1A1A);
const kProfileDarkTile = Color(0xFF2C2C2C);
const kProfileAccentYellow = Color(0xFFFFCC4D);

