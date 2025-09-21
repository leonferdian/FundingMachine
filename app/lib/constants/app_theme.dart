import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryVariant = Color(0xFF4A45FF);
  static const Color secondaryColor = Color(0xFF4A45FF);
  static const Color secondaryVariant = Color(0xFF3A36D6);
  
  // Background colors
  static const Color backgroundColor = Color(0xFFF8F9FF);
  static const Color surfaceColor = Colors.white;
  
  // Text colors
  static const Color textColor = Color(0xFF2D3748);
  static const Color lightTextColor = Color(0xFF718096);
  static const Color onPrimaryColor = Colors.white;
  static const Color onSecondaryColor = Colors.white;
  static const Color onBackgroundColor = Color(0xFF2D3748);
  static const Color onSurfaceColor = Color(0xFF2D3748);
  static const Color onErrorColor = Colors.white;
  
  // Status colors
  static const Color successColor = Color(0xFF48BB78);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color warningColor = Color(0xFFDD6B20);
  static const Color infoColor = Color(0xFF3182CE);
  
  // Other UI colors
  static const Color dividerColor = Color(0xFFE2E8F0);
  static const Color disabledColor = Color(0xFFCBD5E0);
  static const Color highlightColor = Color(0xFFF7FAFC);
  static const Color splashColor = Color(0x66C6F6D5);
  static const Color cardColor = Colors.white;
  static const Color canvasColor = Color(0xFFF8F9FF);

  // Text styles
  static const TextTheme textTheme = TextTheme(
    // Headings
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    // Titles
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    // Body
    bodyLarge: TextStyle(
      fontSize: 16,
      color: textColor,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: lightTextColor,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: lightTextColor,
      height: 1.5,
    ),
    // Buttons
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: onPrimaryColor,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: onPrimaryColor,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: onPrimaryColor,
      letterSpacing: 0.5,
    ),
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      surface: Colors.white,
      surfaceContainerHighest: Colors.grey.shade100,
      onSurface: const Color(0xFF1A1A1A),
      error: errorColor,
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
    ),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    // Dialog theme is set below in the copyWith
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.white,
      elevation: 0,
    ),
    // Text Theme
    textTheme: textTheme,
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      iconTheme: IconThemeData(color: textColor),
    ),
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: textTheme.labelLarge,
      ),
    ),
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: textTheme.labelLarge?.copyWith(color: primaryColor),
      ),
    ),
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: textTheme.labelLarge?.copyWith(color: primaryColor),
      ),
    ),
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(color: lightTextColor),
      hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
      errorStyle: textTheme.bodySmall?.copyWith(color: errorColor),
    ),
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textColor,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      disabledColor: Colors.grey.shade200,
      selectedColor: Color.fromRGBO(
      primaryColor.red,
      primaryColor.green,
      primaryColor.blue,
      0.2,
    ),
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: textTheme.bodySmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: textTheme.bodySmall?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w500,
      ),
      brightness: Brightness.light,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = lightTheme.copyWith(
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryVariant,
      secondary: secondaryColor,
      secondaryContainer: secondaryVariant,
      surface: const Color(0xFF1E1E2D),
      surfaceContainerHighest: Color.fromRGBO(45, 55, 72, 0.5),
      error: errorColor,
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
      onSurface: Colors.white,
      onError: onErrorColor,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E2D),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Color(0xFF1E1E2D),
    ),
    dividerColor: const Color(0xFF2D3748),
    textTheme: TextTheme(
      displayLarge: textTheme.displayLarge?.copyWith(color: Colors.white),
      displayMedium: textTheme.displayMedium?.copyWith(color: Colors.white),
      displaySmall: textTheme.displaySmall?.copyWith(color: Colors.white),
      titleLarge: textTheme.titleLarge?.copyWith(color: Colors.white),
      titleMedium: textTheme.titleMedium?.copyWith(color: Colors.white),
      titleSmall: textTheme.titleSmall?.copyWith(color: Colors.white),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        color: const Color.fromRGBO(255, 255, 255, 0.9),
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        color: const Color.fromRGBO(255, 255, 255, 0.8),
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        color: const Color.fromRGBO(255, 255, 255, 0.7),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E2D),
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: const Color.fromRGBO(45, 55, 72, 0.5),
      hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
      labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade800),
      ),
      color: const Color(0xFF1E1E2D),
    ),
  );
}
