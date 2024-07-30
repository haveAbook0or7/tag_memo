import 'package:flutter/material.dart';

import 'theme_type.dart';

class CustomMaterialColor{
  /*
   * カスタムMaterialColorの定義。
   */
  static const int _rosePrimaryValue = 0xffe95464;
  static const MaterialColor rose = MaterialColor(
    _rosePrimaryValue,
    <int, Color>{
      50 : Color(0xffffffff),
      100 : Color(0xff9d8e87), // ローズグレイ
      200 : Color(0xffe95464), // ローズ
      300 : Color(0xfff19ca7), // ローズピンク
      400 : Color(0xffea553a),
      500 : Color(0xfffdd35c),
      600 : Color(0xffd9e367),
      700 : Color(0xff003f8e),
      800 : Color(0xffb79fcb),
      900 : Color(0xffe29399),
    },
  );

  static const int _skyPrimaryValue = 0xff6c9bd2;
  static const MaterialColor sky = MaterialColor(
    _skyPrimaryValue,
    <int, Color>{
      50 : Color(0xffffffff),
      100 : Color(0xff719bad), // シャドウブルー
      200 : Color(0xff6c9bd2), // ヒヤシンス
      300 : Color(0xffa0d8ef), // スカイブルー
      400 : Color(0xffea553a),
      500 : Color(0xfff19072),
      600 : Color(0xff001e43),
      700 : Color(0xffd3cfd9),
      800 : Color(0xff895b8a),
      900 : Color(0xfff6bfbc),
    },
  );

  static const int _pastelPrimaryValue = 0xff6c9bd2;
  static const MaterialColor pastel = MaterialColor(
    _pastelPrimaryValue,
    <int, Color>{
      50 : Color(0xffffffff),
      100 : Color(0xffbcc7d7),
      200 : Color(0xff67b5b7),
      300 : Color(0xfffbdac8),
      400 : Color(0xfffff3b8),
      500 : Color(0xffbee0c2),
      600 : Color(0xffbbe2f1),
      700 : Color(0xffd3cfd9),
      800 : Color(0xffe0b5d3),
      900 : Color(0xfff6bfbc),
    },
  );


  static Map<String, MaterialColor> toMap() {
    return {
      ThemeType.ROSE: rose,
      ThemeType.SKY: sky,
      ThemeType.PASTEL: pastel,
    };
  }

  @override
  String toString() {
    return toMap() as String;
  }

}
