import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'color.dart';
import 'theme_type.dart';
import 'package:tag_memo/data/sharedPreferences.dart';

class ThemeColor {

  static Map<String, MaterialColor> appThemeColor = MyColor.toMap();

  // SharedPreferencesに保存されているテーマ名を取得。
  Future<String> _getThemeName() async {
    // SharedPreferenceから取得したテーマ名を返す
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPreferencesKeys.appThemeKey) ?? ThemeType.ROSE;
  }

  Future<MaterialColor> getThemeColor() async {
    final key = await _getThemeName();

    return appThemeColor[key]!;
  }

  Future<MaterialColor> getBasicAndThemeColor() async {
    final key = await _getThemeName();

    final themeColor = appThemeColor[key]!;
    final colors =  MaterialColor(
      0xffffffff,
      <int, Color>{
        50 : const Color(0xffffffff),
        100 : const Color(0xff2b2b2b),
        200 : const Color(0xffee836f),
        300 : const Color(0xfffcd575),
        400 : const Color(0xffbce2e8),
        500 : themeColor[300]!,
        600 : themeColor[400]!,
        700 : themeColor[500]!,
        800 : themeColor[600]!,
        900 : themeColor[800]!,
      },
    );

    return colors;
  }

  // static Future<ThemeType> loadThemeType() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   return ThemeType.of(prefs.getString('theme_type')!) ?? ThemeType.rose;
  // }

}
