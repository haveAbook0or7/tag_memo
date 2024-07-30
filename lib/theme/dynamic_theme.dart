import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './app_theme.dart';
import './theme_type.dart';
import '../data/shared_preferences/sharedPreferences.dart';


typedef ThemedWidgetBuilder = Widget Function(BuildContext context, ThemeData data);

class DynamicTheme extends StatefulWidget {
  /*
  * 動的にアプリテーマを変更するクラス。
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
  final String defaultThemeName;
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
  ThemeData get themeData => _themeData;
  // アプリに設定するテーマ名。
  late String _themeName;
  // 記録されているテーマを操作するか。
  bool _shouldLoadThemeTypes = true;

  // 定義されているThemeDataを取得。
  Map<String, ThemeData> appThemeData = AppTheme.toMap();


  @override
  void initState() {
    super.initState();

    // 変数を初期化。
    _initVariables();
    // 記録されているテーマデータ読み込み。
    loadThemeType();
  }

  void _initVariables() {
    /// 変数を初期化。
    _themeName = widget.defaultThemeName;
    _shouldLoadThemeTypes = widget.loadThemeTypesOnStart;
  }

  Future<void> loadThemeType() async {
    /// _shouldLoadThemeTypesの値に応じて記録されているテーマデータを読み込む。
    // 保存されているテーマを使用したくない場合は処理を終了する。
    if (!_shouldLoadThemeTypes) {
      return;
    }

    _themeName = await _getThemeName();

    setState(() {
      _themeData = appThemeData[_themeName]!;
    });
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
