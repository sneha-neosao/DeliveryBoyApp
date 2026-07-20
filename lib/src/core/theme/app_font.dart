import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized font definition for the entire app.
/// Font family: Albert Sans.
/// To change the font app-wide, update only [_fontFamily] below.
class AppFont {
  AppFont._();

  // ── Single source of truth ─────────────────────────────────────────────────
  static const String _fontFamily = 'Geist';

  /// Returns a sans-serif [TextStyle].
  /// Only pass [fontSize], [fontWeight], [color], [height], [letterSpacing] —
  /// never hard-code the font family in individual screens.
  static TextStyle style({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  // ── Legacy helpers (kept for existing theme wiring) ────────────────────────
  static TextStyle get normal =>
      const TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.normal);

  static TextStyle get bold =>
      const TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold);

  /// The raw font family string — used in ThemeData.fontFamily.
  static String get family => _fontFamily;
}

// ── Size extension (unchanged) ─────────────────────────────────────────────────
extension AppFontSize on TextStyle {
  TextStyle get s12 => copyWith(fontSize: 12.sp);
  TextStyle get s14 => copyWith(fontSize: 14.sp);
  TextStyle get s16 => copyWith(fontSize: 16.sp);
  TextStyle get s17 => copyWith(fontSize: 17.sp);
  TextStyle get s18 => copyWith(fontSize: 18.sp);
  TextStyle get s20 => copyWith(fontSize: 20.sp);
  TextStyle get s22 => copyWith(fontSize: 22.sp);
  TextStyle get s25 => copyWith(fontSize: 25.sp);
  TextStyle get s30 => copyWith(fontSize: 30.sp);
}
