import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'color.dart';
import 'theme_type.dart';
import 'package:tag_memo/data/sharedPreferences.dart';


typedef ThemedWidgetBuilder = Widget Function(BuildContext context, ThemeData data);

class DynamicTheme extends StatefulWidget {
  /*
  * テーマカラー
  */
  const DynamicTheme({
    Key? key,
    required this.themedWidgetBuilder,
    this.defaultThemeName = ThemeType.ROSE,
    this.loadThemeTypesOnStart = true,
  }) : super(key: key);

  // テーマが変更されたときに呼び出されるビルダー
  final ThemedWidgetBuilder themedWidgetBuilder;
  // 起動時のデフォルトのテーマ > 初期値: ThemeType.rose
  final String defaultThemeName; // 初期値
  // 起動時にテーマを読み込むかどうか > 初期値: true
  final bool loadThemeTypesOnStart;

  @override
  DynamicThemeState createState() => DynamicThemeState();

  static DynamicThemeState? of(BuildContext context) {
    return context.findAncestorStateOfType<DynamicThemeState>();
  }

}

class DynamicThemeState extends State<DynamicTheme> {

  // アプリに設定するテーマ。
  late ThemeData _themeData;

  // アプリに設定するテーマ名。
  late String _themeName;

  bool _shouldLoadThemeTypes = true;

  // 現在の `ThemeData` を取得します
  ThemeData get themeData => _themeData;

  Map<String, ThemeData> appThemeData = AppTheme.toMap();

  @override
  void initState() {
    super.initState();

    _initVariables();

    _themeData = ThemeData(
      primaryColor: MyColor.rose[2],
      // accentColor: MyColor.rose[1],
      // selectedRowColor: MyColor.rose[4],
      brightness: Brightness.light,
    );

    loadThemeType();

  }

  // `loadBrightnessOnStart` 値に応じて明るさをロードします
  Future<void> loadThemeType() async {
    // 保存されているテーマを使用したくない場合は処理を終了する。
    if (!_shouldLoadThemeTypes) {
      return;
    }

    _themeName = await _getThemeName();

    setState(() {
      _themeData = appThemeData[_themeName]!;
    });

  }
  // 変数を初期化します
  void _initVariables() {
    _themeName = widget.defaultThemeName;
    _shouldLoadThemeTypes = widget.loadThemeTypesOnStart;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeData = appThemeData[_themeName]!;
  }

  @override
  void didUpdateWidget(DynamicTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    _themeData = appThemeData[_themeName]!;
  }

  // SharedPreferencesに保存されているテーマ名を取得。
  Future<String> _getThemeName() async {
    // SharedPreferenceから取得したテーマ名を返す
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPreferencesKeys.appThemeKey) ?? widget.defaultThemeName;
  }

  // テーマを設定。
  // ツリーを再構築。
  Future<void> setTheme(String themeName) async {
    setState(() {
      _themeName = themeName;
      _themeData = appThemeData[themeName]!;
    });

    // テーマを保存。
    await _saveThemeName(themeName);

  }

  // 指定されたテーマ名をSharedPreferencesに保存。
  Future<void> _saveThemeName(String themeName) async {
    // テーマの変更を永続化したくない場合は保存しない。
    if (!_shouldLoadThemeTypes) {
      return;
    }

    // 指定されたテーマを保存。
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPreferencesKeys.appThemeKey, themeName);

  }

  @override
  Widget build(BuildContext context) {
    return widget.themedWidgetBuilder(context, _themeData);
  }

}
