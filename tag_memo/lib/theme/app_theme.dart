import 'package:flutter/material.dart';
import 'color.dart';
import 'theme_type.dart';


class AppTheme {

  static final _themeRose = ThemeData(
    primaryColor: MyColor.rose[100],
    // accentColor: MyColor.rose[200],
    // selectedRowColor: MyColor.rose[300],
    primarySwatch: MyColor.rose,
    brightness: Brightness.light,
  );
  static ThemeData get themeRose => _themeRose;

  static final _themeSky = ThemeData(
    primaryColor: MyColor.sky[100],
    // accentColor: MyColor.sky[200],
    // selectedRowColor: MyColor.sky[300],
    primarySwatch: MyColor.sky,
    brightness: Brightness.light,
  );
  static ThemeData get themeSky => _themeSky;

  static final _themePastel = ThemeData(
      primaryColor: MyColor.pastel[100],
      // accentColor: MyColor.pastel[200],
      // selectedRowColor: MyColor.pastel[300],
      primarySwatch: MyColor.pastel,
      brightness: Brightness.light,
    );
  static ThemeData get themePastel => _themePastel;


  static Map<String, ThemeData> toMap() {
    return {
      ThemeType.ROSE: themeRose,
      ThemeType.SKY: themeSky,
      ThemeType.PASTEL: themePastel,
    };
  }

  @override
  String toString() {
    return toMap() as String;
  }
}
