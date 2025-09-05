import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  static TextStyle orbitron({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final fontFamily = _getFallbackMonospaceFont();

    return TextStyle(
      fontFamily: fontFamily,
      color: color ?? textStyle?.color,
      fontSize: fontSize ?? textStyle?.fontSize,
      fontWeight: fontWeight ?? textStyle?.fontWeight,
      fontStyle: fontStyle ?? textStyle?.fontStyle,
      letterSpacing: letterSpacing ?? textStyle?.letterSpacing,
      wordSpacing: wordSpacing ?? textStyle?.wordSpacing,
      textBaseline: textBaseline ?? textStyle?.textBaseline,
      height: height ?? textStyle?.height,
      decoration: decoration ?? textStyle?.decoration,
      decorationColor: decorationColor ?? textStyle?.decorationColor,
      decorationStyle: decorationStyle ?? textStyle?.decorationStyle,
      decorationThickness: decorationThickness ?? textStyle?.decorationThickness,
    ).merge(textStyle);
  }

  static TextStyle exo2({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontFamily: _getFallbackSansSerifFont(),
      color: color ?? textStyle?.color,
      fontSize: fontSize ?? textStyle?.fontSize,
      fontWeight: fontWeight ?? textStyle?.fontWeight,
      fontStyle: fontStyle ?? textStyle?.fontStyle,
      letterSpacing: letterSpacing ?? textStyle?.letterSpacing ?? 0.5,
      wordSpacing: wordSpacing ?? textStyle?.wordSpacing,
      textBaseline: textBaseline ?? textStyle?.textBaseline,
      height: height ?? textStyle?.height,
      decoration: decoration ?? textStyle?.decoration,
      decorationColor: decorationColor ?? textStyle?.decorationColor,
      decorationStyle: decorationStyle ?? textStyle?.decorationStyle,
      decorationThickness: decorationThickness ?? textStyle?.decorationThickness,
    ).merge(textStyle);
  }

  static TextStyle inter({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontFamily: _getFallbackSansSerifFont(),
      color: color ?? textStyle?.color,
      fontSize: fontSize ?? textStyle?.fontSize,
      fontWeight: fontWeight ?? textStyle?.fontWeight,
      fontStyle: fontStyle ?? textStyle?.fontStyle,
      letterSpacing: letterSpacing ?? textStyle?.letterSpacing,
      wordSpacing: wordSpacing ?? textStyle?.wordSpacing,
      textBaseline: textBaseline ?? textStyle?.textBaseline,
      height: height ?? textStyle?.height ?? 1.2,
      decoration: decoration ?? textStyle?.decoration,
      decorationColor: decorationColor ?? textStyle?.decorationColor,
      decorationStyle: decorationStyle ?? textStyle?.decorationStyle,
      decorationThickness: decorationThickness ?? textStyle?.decorationThickness,
    ).merge(textStyle);
  }

  static String _getFallbackSansSerifFont() {
    return 'Roboto'; // Android default, will fallback to system font on other platforms
  }

  static String _getFallbackMonospaceFont() {
    return 'monospace'; // Cross-platform monospace fallback
  }

  static ThemeData getAppTheme({bool isDarkMode = false}) {
    final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.copyWith(
        displayLarge: orbitron(textStyle: baseTheme.textTheme.displayLarge),
        displayMedium: orbitron(textStyle: baseTheme.textTheme.displayMedium),
        displaySmall: orbitron(textStyle: baseTheme.textTheme.displaySmall),
        headlineLarge: orbitron(textStyle: baseTheme.textTheme.headlineLarge),
        headlineMedium: orbitron(textStyle: baseTheme.textTheme.headlineMedium),
        headlineSmall: orbitron(textStyle: baseTheme.textTheme.headlineSmall),
        titleLarge: orbitron(textStyle: baseTheme.textTheme.titleLarge),
        titleMedium: orbitron(textStyle: baseTheme.textTheme.titleMedium),
        titleSmall: orbitron(textStyle: baseTheme.textTheme.titleSmall),
        bodyLarge: inter(textStyle: baseTheme.textTheme.bodyLarge),
        bodyMedium: inter(textStyle: baseTheme.textTheme.bodyMedium),
        bodySmall: inter(textStyle: baseTheme.textTheme.bodySmall),
        labelLarge: inter(textStyle: baseTheme.textTheme.labelLarge),
        labelMedium: inter(textStyle: baseTheme.textTheme.labelMedium),
        labelSmall: inter(textStyle: baseTheme.textTheme.labelSmall),
      ),
    );
  }
}
