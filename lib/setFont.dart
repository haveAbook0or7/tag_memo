import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customWidget/dropdownTile.dart';

class SetFont extends StatefulWidget {
  @override
  _SetFontState createState() => _SetFontState();
}

class _SetFontState extends State<SetFont> {
  /// データを保存するやつ
  late SharedPreferences prefs;
  /// ドロップダウンデータ
  List<String> fontSizes = List.generate(20, (index) => (16+index).toString());
  Map<String,Color> fontColors = {
    'ブラック': Colors.black,
    'ダークグレイ': Colors.black45,
    'ホワイト': Colors.white
  };
  /// 今の値
  late String fsize;
  late String fcolor;

  Future<dynamic> loading() async {
    prefs = await SharedPreferences.getInstance();
    fsize = (prefs.getDouble('fontSize') ?? 16).toInt().toString();
    fcolor = prefs.getString('fontColor') ?? 'ブラック';
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('フォント設定'),),
      /******************************************************* AppBar*/
      body: FutureBuilder(
        future: loading(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData){
              return ListView.separated(
                itemCount: 3,
                itemBuilder: (context, index) {
                  final item = <Widget>[
                    /** プレビュー */
                    Container(
                      height: 120,
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Column(children: [
                        Container(
                          alignment: Alignment.topLeft, 
                          padding: const EdgeInsets.only(left: 5),
                          child: const Text('プレビュー'),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xfffcd575),
                            border: Border(
                              left: BorderSide(color: Colors.black45, width: 1),
                              top: BorderSide(color: Colors.black45, width: 1),
                            ),
                          ),
                          child: Text('あいうABCabc亜衣宇', style: TextStyle(fontSize: double.parse(fsize), color: fontColors[fcolor]),)
                        )
                      ],)
                    ),
                    /** フォントサイズ */
                    DropdownTile(
                      title: 'フォントサイズ',
                      value: fsize,
                      items: fontSizes,
                      onChanged: (String value) async {
                        setState(() => fsize = value);
                        prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('fontSize', double.parse(value));
                      },
                    ),
                    /** フォントカラー */
                    DropdownTile(
                      title: 'フォントカラー',
                      value: fcolor,
                      items: fontColors.keys.toList(),
                      onChanged: (String value) async {
                        setState(() => fcolor = value);
                        prefs = await SharedPreferences.getInstance();
                        await prefs.setString('fontColor', value);
                      },
                    )
                  ];
                  /** アイテムを順番に並べる */
                  return item[index];
                },
                separatorBuilder: (context, index) => const Divider(height: 3)
              );
            } else {
              return const CircularProgressIndicator();
            }
        },
      ),
    );
  }
}
