// ignore: file_names
import 'dart:math';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:tag_memo/customWidget/husenContainer.dart';


class ReorderableHusenView extends StatefulWidget {

  ReorderableHusenView.builder({
    int crossAxisCount = 3,
    double axisSpacing = 4.0,
    required Widget? Function(int) itembuilder,
    required int itemcount,
    required dynamic Function(int) callbackbuilder,
    HusenColor? Function(int)? colorsbuilder,
    required void Function(List<dynamic> callbackList, int oldIndex, int newIndex,) onReorder,
    required void Function(int index) onTap,
    Key key = const Key(''),
  }) : this._init(
    crossAxisCount: crossAxisCount,
    axisSpacing: axisSpacing,
    children: List.generate(itemcount, (index){
      return itembuilder(index);
    }),
    callbackList: List.generate(itemcount, (index){
      return callbackbuilder(index);
    }),
    colors: List.generate(itemcount, (index){
      if(colorsbuilder == null){
        final color = Colors.blue[200]!;
        return HusenColor(color: color,backSideColor: Color.fromARGB(255, color.red-50, color.green-50, color.blue-50));
      }
      return colorsbuilder(index);
    }),
    onReorder:onReorder,
    onTap:onTap,
    key: key,
  );
  ReorderableHusenView._init({
    Key? key, 
    this.crossAxisCount = 3,
    this.axisSpacing = 4.0,
    required this.children,
    required this.callbackList,
    required this.colors,
    required this.onReorder,
    required this.onTap,
  }) : super(key: key);

  /// 列の数
  final int crossAxisCount;
  /// 付箋と付箋の間の隙間
  final double axisSpacing;
  /// アイテム数
  late int itemcount;
  /// アイテム
  late List<Widget?> children = [];
  late Widget Function(int) itembuilder;
  /// 入れ替え後返して欲しい配列データを入れる。キーとか
  late List<dynamic> callbackList = [];
  late dynamic Function(int) keybuilder;
  /// 付箋の色
  late List<HusenColor?> colors = [];
  late HusenColor Function(int) colorsbuilder;
  /// 入れ替え後keysを親へ渡す
  late void Function(List<dynamic> callbackList, int oldIndex, int newIndex,) onReorder;
  /// ジェスチャー類
  late void Function(int index) onTap;
  /// 定数
  final String imgPath = 'images/Wood_Cedar.jpeg';
  final Size imgOriginSize = const Size(800, 500);

  @override
  ReorderableHusenViewState createState() => ReorderableHusenViewState();
}

class ReorderableHusenViewState extends State<ReorderableHusenView> {
  final AsyncMemoizer<void> memoizer = AsyncMemoizer();
  // プレビューウィジェットデータ
  PreviewItem preview = PreviewItem();

  List<dynamic> endNullDelete(List<dynamic> list) {
    /** List末尾のnullを削除する関数 */
    for (var i = list.length - 1; i >= 0; i--) {
      if (list[i] != null) {
        break;
      }
      list.removeAt(i);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    /** ウィジェット */
    return LayoutBuilder(builder: (context, constraints) {
      /** グリッドアイテムサイズ */
      final gredSize = (constraints.maxWidth - widget.axisSpacing * (widget.crossAxisCount - 1)) / widget.crossAxisCount;

      /** グリッドビュー背景の高さ */
      /// グリッドアイテム2行分大きく設定
      final rowCount = (widget.children.length / widget.crossAxisCount).ceil();
      var backgroundHeight = gredSize * rowCount + widget.axisSpacing * (rowCount - 1) + gredSize * 2;
      /// ウィジェットのHeightより小さかったらウィジェットのHeightに変える */
      backgroundHeight = max(backgroundHeight, constraints.maxHeight);

      /** 木目の背景を何枚配置するか */
      final backImgHeight = constraints.maxWidth / widget.imgOriginSize.width * widget.imgOriginSize.height;
      final backimgCount = (backgroundHeight / backImgHeight).ceil();
      /// 木目の背景imgがウィジェットからはみ出さないように調整
      backgroundHeight = max(backgroundHeight, backImgHeight * backimgCount);

      /** SetState時に再設定されるとおかしくなるので最初の一回だけ設定 */
      memoizer.runOnce(() async {
        /** プレビュー用アイテムを画面外に飛ばす */
        preview..top = -gredSize
        ..left = -gredSize;
      });

      /** 各アイテムのPositionを設定 */
      final childlenPosition = List<Offset?>.generate(
        widget.children.length,
        (index) => Offset(
          index % widget.crossAxisCount * (gredSize + widget.axisSpacing), 
          index ~/ widget.crossAxisCount * (gredSize + widget.axisSpacing),
        ),
      );

      /** グリッドビュー */
      return SingleChildScrollView(
        child: SizedBox(
          height: backgroundHeight,
          /** プレビュー用アイテムが一番上にするためStackを二重にする */
          child: Stack(children: [
            /** 木目の背景 */
            Column(children: List.generate(backimgCount, (index) => Image.asset(widget.imgPath))),
            /** アイテム */
            Stack(children: List.generate(widget.children.length, (index) {
              return Positioned(
                top: childlenPosition[index]!.dy,
                left: childlenPosition[index]!.dx,
                child: GestureDetector(
                  onTap: (){
                    widget.onTap(index);
                  },
                  // ----- 付箋入れ替え開始処理 -----------------------------------
                  onLongPressStart: (LongPressStartDetails details) {
                    setState(() {
                      /** フラグをセット */
                      preview.isMove = widget.children[index] != null;
                      /// アイテムが空の場合、今後の処理をキャンセル
                      if(!preview.isMove){ return; }

                      /** プレビューウィジェットに移動するアイテムを移す */
                      preview..top = childlenPosition[index]!.dy
                      ..left = childlenPosition[index]!.dx
                      ..previewChild = widget.children[index]
                      ..previewColor = widget.colors[index]
                      ..previewCallbackData = widget.callbackList[index];
                      /** 元のアイテムを削除 */
                      widget.children[index] = null;
                    });
                  },
                  // ----- 付箋入れ替え移動処理 -----------------------------------
                  onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
                    if(preview.isMove){
                      setState(() {
                        /** 動きに合わせてプレビューウィジェットの座標を補正する */
                        preview..top = childlenPosition[index]!.dy + details.offsetFromOrigin.dy
                        ..left = childlenPosition[index]!.dx + details.offsetFromOrigin.dx;
                      });
                    }
                  },
                  // ----- 付箋入れ替え終了処理 -----------------------------------
                  onLongPressEnd: (LongPressEndDetails details) async {
                    if (preview.isMove) {
                      /** 移動先の座標 */
                      final dx = childlenPosition[index]!.dx + details.localPosition.dx;
                      final dy = childlenPosition[index]!.dy + details.localPosition.dy;
                      /** 移動先index算出 */
                      final moved = widget.crossAxisCount * (dy ~/ gredSize) + (dx ~/ gredSize); //差分
                      setState(() {
                        /** 移動先が配列サイズを超えるなら拡張する */
                        if (moved >= widget.children.length) {
                          final expansion = List.generate(moved + 1 - widget.children.length, (index) => null);

                          widget..children.addAll(expansion)
                          ..colors.addAll(expansion)
                          ..callbackList.addAll(expansion);
                          childlenPosition.addAll(expansion);
                        }
                        /// 入れ替え
                        /** 移動先のデータを移動元にセット */
                        widget.children[index] = widget.children[moved];
                        widget.colors[index] = widget.colors[moved];
                        widget.callbackList[index] = widget.callbackList[moved];
                        /** プレビューアイテムアイテムに退避していたデータを移動先にセット */
                        widget.children[moved] = preview.previewChild;
                        widget.colors[moved] = preview.previewColor;
                        widget.callbackList[moved] = preview.previewCallbackData;

                        /** 各リストの末尾の空白を消す */
                        widget..children = endNullDelete(widget.children) as List<Widget?>
                        ..colors = endNullDelete(widget.colors) as List<HusenColor?>
                        ..callbackList = endNullDelete(widget.callbackList);

                        /** プレビュー用アイテムを画面外に飛ばす */
                        preview..previewChild = null
                        ..previewColor = null
                        ..top = -gredSize
                        ..left = -gredSize;
                      });

                      /** onReorderを発火 */
                      widget.onReorder(
                        widget.callbackList, 
                        index,
                        moved,
                      );
                    }
                  },
                  /** アイテム */
                  child: Container(
                    width: gredSize, height: gredSize, 
                    color: Colors.transparent,
                    child: widget.children[index] != null ? 
                      HusenContainer(
                        husencolor: widget.colors[index],
                        mekuriFlg: false,
                        child: SizedBox(width: gredSize, height: gredSize, child: widget.children[index]),
                      ) : 
                      null,
                  ),
                ),
              );
            }),),
            /** プレビューウィジェット */
            Positioned(
              top: preview.top,
              left: preview.left,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: preview.previewChild == null ? null : [const BoxShadow(
                    color: Colors.black12, 
                    blurRadius: 10, 
                    spreadRadius: 1, 
                    offset: Offset(5, 5),)
                  ],), 
                child: HusenContainer(
                  husencolor: preview.previewColor,
                  mekuriFlg: true,
                  child: SizedBox(width: gredSize, height: gredSize, child: preview.previewChild),
                ),
              ),
            ),
          ],),
        ),
      );
    },);
  }
}

class PreviewItem {
  /*
  * 
  * 
  * 
  */ 
  PreviewItem({ 
    this.isMove = true,
    this.top = 0.0,
    this.left = 0.0,
    this.previewChild,
    this.previewColor,
    this.previewCallbackData,
  });

  bool isMove;
  double top;
  double left;
  Widget? previewChild;
  HusenColor? previewColor;
  dynamic previewCallbackData;


  Map<String, dynamic> toMap() {
    return {
      'isMove': isMove,
      'top': top,
      'left': left,
      'previewChild': previewChild,
      'previewColor': previewColor,
      'previewCallbackData': previewCallbackData,
    };
  }

  @override
  String toString() {
    return 'PreviewItem{isMove: $isMove, top: $top, left: $left, previewChild: $previewChild, previewColor: $previewColor, previewCallbackData: $previewCallbackData}';
  }

}
