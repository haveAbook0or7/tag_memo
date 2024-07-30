class ThemeType {
  // const ThemeType(this._value);
  // final String _value;
  // String get value => _value;

  // ignore: constant_identifier_names
  static const String ROSE = 'ROSE';
  // ignore: constant_identifier_names
  static const String SKY = 'SKY';
  // ignore: constant_identifier_names
  static const String PASTEL = 'PASTEL';

  // static const ThemeType rose = ThemeType(_roseValue);
  // static const ThemeType sky = ThemeType(_skyValue);
  // static const ThemeType pastel = ThemeType(_pastelValue);

  List<String> values() {
    // 
    return [
      ThemeType.ROSE,
      ThemeType.SKY,
      ThemeType.PASTEL,
    ];
  }


  // static ThemeType of(String theme) {
  //   return ThemeType.values().firstWhere(
  //     (e) => e.toString() == theme,
  //     // orElse: () => null
  //   );
  // }

  // @override
  // String toString() {
  //   return value;
  // }
}
