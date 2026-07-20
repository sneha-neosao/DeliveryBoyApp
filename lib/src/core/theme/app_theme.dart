import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_color.dart';
import 'app_font.dart';

/// utility class to define the app theme
class AppTheme {
  AppTheme._();

  static ThemeData data(bool isDark) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,

      primaryColor: AppColor.primary,

      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColor.primary,
        onPrimary: Colors.white,
        secondary: AppColor.secondary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: AppColor.card,
        onSurface: AppColor.black,
      ),

      scaffoldBackgroundColor:
      isDark ? const Color(0xFF1C1C1C) : AppColor.white,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.black,
        centerTitle: true,
      ),

      cardColor: AppColor.card,

      dividerColor: AppColor.border,

      iconTheme: const IconThemeData(
        color: AppColor.primary,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColor.primary,
            width: 2,
          ),
        ),
      ),

      // Keep your existing ElevatedButtonTheme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 61.h),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
          textStyle: AppFont.bold.s17,
        ),
      ),

      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: AppFont.family,
      textTheme: TextTheme(
        bodySmall: AppFont.normal.s12.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyMedium: AppFont.normal.s14.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyLarge: AppFont.normal.s16.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
        headlineSmall: AppFont.bold.s12.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
        headlineMedium: AppFont.bold.s16.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
        headlineLarge: AppFont.bold.s18.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
        displaySmall: AppFont.bold.s22.copyWith(
          color: isDark ? Colors.white : Colors.black,
          height: 22 / 22,
        ),
        displayMedium: AppFont.bold.s25.copyWith(
          color: isDark ? Colors.white : Colors.black,
          height: 22 / 31,
        ),
        displayLarge: AppFont.bold.s30.copyWith(
          color: isDark ? Colors.white : Colors.black,
          height: 22 / 30,
        ),
      ),
    );
  }
}