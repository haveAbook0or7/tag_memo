import 'package:flutter/material.dart';
import 'package:tag_memo/theme/custom_material_color.dart';
import 'package:tag_memo/theme/theme_type.dart';


class AppTheme {
  /*
   * アプリのThemeDataの定義。
   */
  static final _themeDataRose = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: CustomMaterialColor.rose,
      primary: CustomMaterialColor.rose[100],
      secondary: CustomMaterialColor.rose[200],
      tertiary: CustomMaterialColor.rose[300],
    ),
    brightness: Brightness.light,
    
  );
  static ThemeData get themeDataRose => _themeDataRose;

  static final _themeDataSky = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: CustomMaterialColor.sky,
      primary: CustomMaterialColor.sky[100],
      secondary: CustomMaterialColor.sky[200],
      tertiary: CustomMaterialColor.sky[300],
    ),
    brightness: Brightness.light,
  );
  static ThemeData get themeDataSky => _themeDataSky;

  static final _themeDataPastel = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: CustomMaterialColor.pastel,
      primary: CustomMaterialColor.pastel[100],
      secondary: CustomMaterialColor.pastel[200],
      tertiary: CustomMaterialColor.pastel[300],
    ),
    brightness: Brightness.light,
  );
  static ThemeData get themeDataPastel => _themeDataPastel;


  static Map<String, ThemeData> toMap() {
    return {
      ThemeType.ROSE: themeDataRose,
      ThemeType.SKY: themeDataSky,
      ThemeType.PASTEL: themeDataPastel,
    };
  }

  @override
  String toString() {
    return toMap() as String;
  }

}
