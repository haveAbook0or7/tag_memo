import 'package:flutter/material.dart';
import 'package:tag_memo/customWidget/customTile.dart';
import 'theme/custom_material_color.dart';
import 'theme/dynamic_theme.dart';
import 'theme/theme_type.dart';

class SetTheme extends StatefulWidget {
  @override
  _SetThemeState createState() => _SetThemeState();
}

class _SetThemeState extends State<SetTheme> {
  @override
  Widget build(BuildContext context) {
    final mapThemeTypeViewName = ThemeType.getViewNames();
    final mapCustomMaterialColor = CustomMaterialColor.toMap();

      return Scaffold(
        appBar: AppBar(title: const Text('テーマカラー設定'),),
        /******************************************************* AppBar*/
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ListView.separated(
              itemCount: mapThemeTypeViewName.length,
              itemBuilder: (context, index) {
                final key = mapThemeTypeViewName.keys.elementAt(index);

                return CustomTile(
                  title: Text(
                    mapThemeTypeViewName[key]!,
                    style: const TextStyle(fontSize: 16,),
                  ),
                  trailing: Row(children: <Widget>[
                    Icon(Icons.stop_circle,color: mapCustomMaterialColor[key]![100],),
                    Icon(Icons.stop_circle,color: mapCustomMaterialColor[key]![200],),
                    Icon(Icons.stop_circle,color: mapCustomMaterialColor[key]![300],),
                  ],),
                  onTap: () async {
                    await DynamicTheme.of(context)?.setTheme(key);
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
