import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade the package to version 8.2.0.
///
/// Use it in a [MaterialApp] like this:
///
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// );
class AppTheme {
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.mallardGreen,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      
      // AppBar customization
      appBarBackgroundSchemeColor: SchemeColor.primaryFixed,
      appBarForegroundSchemeColor: SchemeColor.onSurface,
      appBarIconSchemeColor: SchemeColor.primary,
      appBarActionsIconSchemeColor: SchemeColor.primary,
      appBarCenterTitle: true,
      appBarScrolledUnderElevation: 2.0,

    
      // Global settings
      defaultRadius: 12.0,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.mallardGreen,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      
            // AppBar customization
      appBarBackgroundSchemeColor: SchemeColor.primaryFixed,
      appBarForegroundSchemeColor: SchemeColor.onSurface,
      appBarIconSchemeColor: SchemeColor.primary,
      appBarActionsIconSchemeColor: SchemeColor.primary,
      appBarCenterTitle: true,
      appBarScrolledUnderElevation: 2.0,
      
      defaultRadius: 12.0,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}