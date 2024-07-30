import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_memo/customWidget/customAlert.dart';
import 'package:tag_memo/customWidget/customDialog.dart';
import 'package:tag_memo/customWidget/customText.dart';
import 'package:tag_memo/customWidget/husenContainer.dart';
import 'package:tag_memo/customWidget/reorderableHusenView.dart';
import 'package:tag_memo/customWidget/repairDialog.dart';
import 'package:tag_memo/data/backup/backup.dart';
import 'package:tag_memo/data/other/husen_color_palette.dart';
import 'package:tag_memo/data/shared_preferences/sharedPreferences.dart';
import 'package:tag_memo/data/sqlite/memo.dart';
import 'package:tag_memo/data/sqlite/sqlite.dart';
import 'package:tag_memo/theme/custom_material_color.dart';


class ViewGarbageMemo extends StatefulWidget {
  @override
  _ViewGarbageMemoState createState() => _ViewGarbageMemoState();
}

class _ViewGarbageMemoState extends State<ViewGarbageMemo> {
  late double deviceHeight;
  late double deviceWidth;
  /* リロード時のぐるぐる */
  late Widget? cpi;
  /* 初期化を一回だけするためのライブラリ */
  // ignore: strict_raw_type
  final AsyncMemoizer memoizer = AsyncMemoizer();
  /* テーマカラー */
  MaterialColor themeColor = CustomMaterialColor.rose;
  /* メモプレビューリスト */
  List<Memo?> _previewList = [];

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
    _previewList = await getGarbageMemoPreview();
    /** フォントスタイルを取得 */
    final prefs = await SharedPreferences.getInstance();
    fsize = prefs.getDouble(SharedPreferencesKeys.fontSize) ?? 16.0;
    fcolor = fontColors[(prefs.getString(SharedPreferencesKeys.fontColor) ?? 'ブラック')]!;
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
      appBar: AppBar(title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ゴミ箱'),
          IconButton(icon: const Icon(Icons.restore_page), 
            onPressed: () async {
              /** バックアップデータからの復元確認ダイアログ表示 */
              await showDialog<Map<String, dynamic>>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return CustomDialog(
                    msgtext: '付箋をバックアップデータから復元しますか？',
                    okBtnText: '復元',
                    cancelOnPressed: () => Navigator.of(context).pop({'op': 'cancel', 'status': -1}),
                    okOnPressed: () async {
                      /** 更新終わるまでグルグルを出しとく */
                      setState(() => cpi = const CircularProgressIndicator());
                      /** バックアップデータから復元処理 */
                      final status = await restoreDatas();
                      /** グルグル終わり */
                      setState(() => cpi = null);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop({'op': 'ok', 'status': status});
                    },
                  );
                },
              ).then((res) async {
                if(res!['op'] == 'ok'){ // バックアップからの復元処理を実行した場合、実行結果をアラートで表示する。
                  await showDialog<String>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return CustomAlert(msgtext: res['status'] == 200 ? '付箋の復元に成功しました。' : '付箋の復元に失敗しました。ステータス: ${res['status']}',);
                    },
                  ).then((res) => loading());
                }
              });
            },
          ),
        ],
      ),),
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 7-ctStyleIndex,
                  style: TextStyle(fontSize: fontsizes[ctStyleIndex], color: fcolor, height: 1.4),
                );
              },
              callbackbuilder: (int index){
                return _previewList[index];
              },
              colorsbuilder: (int index){
                /** 空白ならnull */
                if(_previewList[index] == null) { return null; }
                /** アイテムがあるなら色をセット */
                final color = themeColor[_previewList[index]!.backColor];
                final backSide = HSVColor.fromColor(color!);
                return HusenColor(color: color, backSideColor: backSide.withValue(backSide.value-0.15).toColor());
              },
              onTap: (int index) async {
                // アイテムが空の場合、今後の処理をキャンセル
                if(_previewList[index] == null){ return; }
                /** 復元確認ダイアログ */
                await showDialog<String>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return RepairDialog(memoId: _previewList[index]!.memoId,);
                  },
                ).then((value) => loading());
              },
            ),
            /** ロード */
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                alignment: Alignment.topCenter,
                width: 25, height: 25,
                child: cpi,
              ),
            )
        ],);
        
      },),
    );
  }
}
