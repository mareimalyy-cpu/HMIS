import 'package:flutter/material.dart';

extension ThemeHelper on ThemeData {
  bool get isDark => brightness == Brightness.dark;
}

extension GreyTheme on ThemeData {
  MaterialColor get greySwatch => isDark ? _greyDarkSwatch : _greySwatch;
}

extension TextThemeHelper on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}

const _greySwatch = MaterialColor(0xFFFFFAF5, {
  50: Color(0xFFFFFAF5),
  100: Color(0xFFFFF2E0),
  200: Color(0xFFFFE6C7),
  300: Color(0xFFFFD199),
  400: Color(0xFFFFB366),
  500: Color(0xFF241407),
  600: Color(0xFF170D05),
  700: Color(0xFF0F0803),
  800: Color(0xFF080401),
  900: Color(0xFF030100),
});
const _greyDarkSwatch = MaterialColor(0xFF170D05, {
  50: Color(0xFF030100),
  100: Color(0xFF080401),
  200: Color(0xFF0F0803),
  300: Color(0xFF170D05),
  400: Color(0xFF241407),
  500: Color(0xFFFFB366),
  600: Color(0xFFFFD199),
  700: Color(0xFFFFE6C7),
  800: Color(0xFFFFF2E0),
  900: Color(0xFFFFFAF5),
});
