import 'package:flutter/material.dart';
import 'package:tag_memo/customWidget/customTile.dart';
import 'theme/color.dart';
import 'theme/dynamic_theme.dart';
import 'theme/theme_type.dart';

class SetTheme extends StatefulWidget {
  @override
  _SetThemeState createState() => _SetThemeState();
}

class _SetThemeState extends State<SetTheme> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('テーマカラー設定'),),
        /******************************************************* AppBar*/
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ListView.separated(
              itemCount: MyColor.themeName.length,
              itemBuilder: (context, index) {
                return CustomTile(
                  title: Text(
                    MyColor.themeName[index],
                    style: const TextStyle(fontSize: 16,),
                  ),
                  trailing: Row(children: <Widget>[
                    Icon(Icons.stop_circle,color: MyColor.themeColor[index]![100],),
                    Icon(Icons.stop_circle,color: MyColor.themeColor[index]![200],),
                    Icon(Icons.stop_circle,color: MyColor.themeColor[index]![300],),
                  ],),
                  onTap: () async {
                    final themeName = ThemeType().values()[index];
                    await DynamicTheme.of(context)?.setTheme(themeName);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(height:3)
            );
          }
        ),
      );
  }
}
