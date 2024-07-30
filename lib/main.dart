import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_memo/customWidget/husenContainer.dart';
import 'package:tag_memo/data/memo.dart';
import 'package:tag_memo/data/sqlite.dart';
import 'package:tag_memo/editingMemo.dart';
import 'package:tag_memo/theme/color.dart';

import 'customWidget/customText.dart';
import 'customWidget/reorderableHusenView.dart';
import 'setFont.dart';
import 'setTheme.dart';
import 'theme/dynamic_theme.dart';
import 'theme/theme_color.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  //向き指定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,//縦固定
  ]);
  //runApp
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          theme: theme,
          home: const TagMemo(
            title: '付箋メモ',
          ),
        );
      },
    );
  }
}

class TagMemo extends StatefulWidget {
  const TagMemo({Key key = const Key(''), required this.title}) : super(key: key);
  final String title;
  @override
  _TagMemoState createState() => _TagMemoState();
}

class _TagMemoState extends State<TagMemo> {
  late double deviceHeight;
  late double deviceWidth;
  /* リロード時のぐるぐる */
  late Widget? cpi;
  /* 初期化を一回だけするためのライブラリ */
  final AsyncMemoizer memoizer = AsyncMemoizer();
  /* テーマカラー */
  MaterialColor themeColor = MyColor.rose;
  /* メモプレビューリスト */
  List<Memo?> _previewList = [];

  List<Widget?> leadingIcon = [null, const Icon(Icons.format_color_fill), const Icon(Icons.text_fields)];
  List<String?> titleText = [null, 'テーマカラー', 'フォント'];
  List<Widget?> onTap = [null, SetTheme(), SetFont()];

  Map<String,Color> fontColors = {'ブラック': Colors.black, 'ダークグレイ': Colors.black45, 'ホワイト': Colors.white};
  double fsize = 16;
  Color fcolor = Colors.white;

  /* ローディング処理 */
  Future<void> loading() async {
    /** 更新終わるまでグルグルを出しとく */
    setState(() => cpi = const CircularProgressIndicator());
    /** テーマカラーを取得 */
    themeColor = await ThemeColor().getBasicAndThemeColor();
    /** プレビューリスト取得 */
    _previewList = await getMemoPreview();
    final prefs = await SharedPreferences.getInstance();
    fsize = prefs.getDouble('fontSize') ?? 16.0;
    fcolor = fontColors[(prefs.getString('fontColor') ?? 'ブラック')]!;
    /** グルグル終わり */
    setState(() => cpi = null);
  }

  @override
  void initState() {
    memoizer.runOnce(() async => loading());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /** 画面 */
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
      drawer: Drawer(
        child: ListView.builder(
        itemCount: leadingIcon.length,
        itemBuilder: (context, index) {
          if(index == 0){ /// 先頭はヘッダー
            return DrawerHeader(decoration: BoxDecoration(color: Theme.of(context).primaryColor,), child: null,);
          }
          return ListTile(
            leading:leadingIcon[index], // 左のアイコン
            title: Text(titleText[index]!), // テキスト
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  // 設定へ
                  return onTap[index]!;
                },),
              ).then((value) async {
                await loading();
              });
            },
          );
        }),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        deviceHeight = constraints.maxHeight;
        deviceWidth = constraints.maxWidth;
        final fontsizes = <double>[10, 12, 14, 16.5];
        final ctStyleIndex = (fsize.toInt()-16)~/5;

        return Stack(children: [
            ReorderableHusenView.builder(
              itemcount: _previewList.length,
              itembuilder: (int index) {
                /** 空白ならnull */
                if(_previewList[index] == null){
                  return null;
                }
                /** アイテムがあるならプレビュー表示 */
                return CustomText(
                  _previewList[index]!.memoPreview ?? '',
                  overflow: TextOverflow.ellipsis, maxLines: 7-ctStyleIndex,
                  style: TextStyle(fontSize: fontsizes[ctStyleIndex], color: fcolor),
                );
              },
              keybuilder: (int index){
                return _previewList[index];
              },
              colorsbuilder: (int index){
                /** 空白ならnull */
                if(_previewList[index] == null) { return null;}
                /** アイテムがあるなら色をセット */
                final color = themeColor[_previewList[index]!.backColor];
                final backSide = HSVColor.fromColor(color!);
                return HusenColor(color: color, backSideColor: backSide.withValue(backSide.value-0.15).toColor());
              },
              onReorder: (List<dynamic> callbacData) async {
                final memoIds = <int>[];
                for(final cblist in callbacData){
                  if(cblist == null){
                    memoIds.add(0);
                  }else{
                    // memoIds.add(cblist.memoId);
                    memoIds.add(cblist as int);
                  }
                }
                await renewMemoOrder(memoIds);
                await loading();
              },
              onTap: (int index){
                if(_previewList[index] == null){ return;}
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    // メモ編集画面へ
                    return EditingMemo(memoId: _previewList[index]!.memoId,);
                  }),
                ).then((value) async {
                  await loading();
                });
              },
            ),
            /** ロード */
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(top: 10),
              child: Container(
                alignment: Alignment.topCenter,
                width: 25, height: 25,
                child: cpi,
              )
            )
        ],);
        
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              // メモ編集画面へ(新規作成)
              return const EditingMemo(memoId: 0,);
            }),
          ).then((value) async {
            await loading();
          });
        },
      ),
    );
  }
}