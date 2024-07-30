class ThemeType {
  // ignore: constant_identifier_names
  static const String ROSE = 'ROSE';
  // ignore: constant_identifier_names
  static const String SKY = 'SKY';
  // ignore: constant_identifier_names
  static const String PASTEL = 'PASTEL';


  static Map<String, String> getViewNames() {
    return {
      ThemeType.ROSE: 'ローズ',
      ThemeType.SKY: 'スカイ',
      ThemeType.PASTEL: 'パステル',
    };
  }

  @override
  String toString() {
    return getViewNames() as String;
  }

}
