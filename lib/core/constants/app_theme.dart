import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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