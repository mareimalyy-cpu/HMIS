import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

const MaterialColor greenSwatch = MaterialColor(0XFF000000, {
  50: Color(0xFFF3FAF6),
  100: Color(0xFFF0F0F0),
  200: Color(0xFFD9E9CF),
  300: Color(0xFFB6CEB4),
  400: Color(0xFF96A78D),
  500: Color(0xFF27391C),
  600: Color(0xFF191919),
  700: Color(0xFF191A19),
  800: Color(0xFF161616),
  900: Color(0xFF0F0E0E),
});

class AppTheme {
  static ThemeData lightTheme({required String fontFamily}) {
    return _buildTheme(
      brightness: Brightness.light,
      baseColor: AppColors.black,
      backgroundColor: AppColors.lightBackground,
      surfaceColor: AppColors.lightSurface,
      dividerColor: AppColors.lightDivider,
      iconColor: AppColors.black,
      errorColor: AppColors.lightError,
      navLabelColor: AppColors.primary,
      navUnselectedColor: AppColors.lightTextSecondary,
      overlayBrightness: Brightness.dark,
      fontFamily: fontFamily,
    );
  }

  static ThemeData darkTheme({required String fontFamily}) {
    return _buildTheme(
      brightness: Brightness.dark,
      baseColor: AppColors.darkText,
      backgroundColor: AppColors.darkBackground,
      surfaceColor: AppColors.darkSurface,
      dividerColor: AppColors.darkDivider,
      iconColor: AppColors.white,
      errorColor: AppColors.darkError,
      navLabelColor: AppColors.primary,
      navUnselectedColor: AppColors.darkTextSecondary,
      overlayBrightness: Brightness.light,
      fontFamily: fontFamily,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color baseColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color dividerColor,
    required Color iconColor,
    required Color errorColor,
    required Color navLabelColor,
    required Color navUnselectedColor,
    required Brightness overlayBrightness,
    required String fontFamily,
  }) {
    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: baseColor),
      bodyMedium: TextStyle(fontSize: 14, color: baseColor),
      bodySmall: TextStyle(
        fontSize: 12,
        color: brightness == Brightness.light
            ? AppColors.lightTextSecondary
            : AppColors.darkTextSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: brightness,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: baseColor,
        onError: AppColors.white,
      ),
      iconTheme: IconThemeData(color: iconColor, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: baseColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: baseColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: overlayBrightness,
          statusBarBrightness: overlayBrightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: overlayBrightness,
          systemNavigationBarContrastEnforced: false,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.teal;
          return brightness == Brightness.dark
              ? Colors.grey[600]
              : Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.teal.withValues(alpha: 0.4);
          }
          return brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[300];
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        labelStyle: TextStyle(color: baseColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: navLabelColor,
        unselectedItemColor: navUnselectedColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      textTheme: textTheme,
    );
  }
}
