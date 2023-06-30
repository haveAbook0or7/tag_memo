import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:tag_memo/customWidget/husenContainer.dart';
import "dart:async";


// ignore: must_be_immutable
class ReorderableHusenView extends StatefulWidget {

  ReorderableHusenView._init({
    this.crossAxisCount = 3,
    this.axisSpacing = 4.0,
    required this.children,
    required this.keys,
    required this.colors,
    required this.onReorder,
    required this.onTap,
    Key key = const Key(''),
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
  late List<dynamic> keys = [];
  late dynamic Function(int) keybuilder;
  /// 付箋の色
  late List<HusenColor?> colors = [];
  late HusenColor Function(int) colorsbuilder;
  /// 入れ替え後keysを親へ渡す
  late void Function(List<dynamic> keys) onReorder;
  /// ジェスチャー類
  late void Function(int index) onTap;

  ReorderableHusenView.builder({
    int crossAxisCount = 3,
    double axisSpacing = 4.0,
    required Widget? Function(int) itembuilder,
    required int itemcount,
    required dynamic Function(int) keybuilder,
    HusenColor? Function(int)? colorsbuilder,
    required void Function(List<dynamic> keys) onReorder,
    required void Function(int index) onTap,
    Key key = const Key(''),
  }) : this._init(
    crossAxisCount: crossAxisCount,
    axisSpacing: axisSpacing,
    children: List.generate(itemcount, (index){
      return itembuilder(index);
    }),
    keys: List.generate(itemcount, (index){
      return keybuilder(index);
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

  @override
  ReorderableHusenViewState createState() => ReorderableHusenViewState();
}

class ReorderableHusenViewState extends State<ReorderableHusenView> {
  final AsyncMemoizer memoizer = AsyncMemoizer();
  /// グリッドビューの高さ
  late double wigetHeight;
  late int imgCount;
  /// グリッドアイテムの大きさ
  late double gredSize;
  /// アイテムのPosition
  List<Offset> fixedPosition = [];
  /// 付箋ウィジェットの制御
  List<bool> mekuriflgs = [];
  /// previewに必要なあれこれ
  bool flg = true;
  Offset startPosition = Offset(0.0, 0.0);
  double top = 0;
  double left = 0;
  Widget? previewItem;
  HusenColor? previewColor;

  @override
  Widget build(BuildContext context) {
    /** ウィジェット */
    return LayoutBuilder(builder: (context, constraints) {
      /** グリッドサイズ */
      gredSize = (constraints.maxWidth - widget.axisSpacing * (widget.crossAxisCount - 1)) / widget.crossAxisCount;
      /** 余裕をもってスクロールできるように設定 */
      wigetHeight = ((widget.children.length ~/ widget.crossAxisCount * gredSize) + widget.children.length ~/ widget.crossAxisCount * widget.axisSpacing) + gredSize * 2;
      /** ウィジェットのHeightより小さかったらウィジェットのHeightに変える */
      wigetHeight = wigetHeight < constraints.maxHeight ? constraints.maxHeight : wigetHeight;
      /** 木目の背景を何枚配置するか(A RenderFlex overflowedが出ないようwigetHeightを修正) */
      imgCount = wigetHeight ~/ (constraints.maxWidth / 8 * 5) + 1;
      wigetHeight = wigetHeight < (constraints.maxWidth / 8 * 5) * imgCount ? (constraints.maxWidth / 8 * 5) * imgCount : wigetHeight;
      /** SetState時に再設定されるとおかしくなるので最初の一回だけ設定 */
      memoizer.runOnce(() async {
        /** プレビュー用アイテムを画面外に飛ばす */
        top = -gredSize;
        left = -gredSize;
      });
      /** 各アイテムのPositionを設定 */
      fixedPosition = [];
      mekuriflgs = [];
      for(int index = 0; index < widget.children.length; index++){
        fixedPosition.add(Offset(
          (index % widget.crossAxisCount * gredSize) + index % widget.crossAxisCount * widget.axisSpacing, 
          (index ~/ widget.crossAxisCount * gredSize) + index ~/ widget.crossAxisCount * widget.axisSpacing
        ));
        mekuriflgs.add(false);
      }
        /** グリッドビュー */
        return SingleChildScrollView(
          child: Container(
            height: wigetHeight,
            /** プレビュー用アイテムが一番上にするためStackを二重にする */
            child: Stack(children: [
              Column(children: List.generate(imgCount, (index) => Image.asset("images/Wood_Cedar.jpeg"))),
              /** アイテム */
              Stack(children: List.generate(widget.children.length, (index) {
                return Positioned(
                  top: fixedPosition[index].dy,
                  left: fixedPosition[index].dx,
                  child: GestureDetector(
                    onTap: (){
                      widget.onTap(index);
                    },
                    onLongPressStart: (LongPressStartDetails details) {
                      /** 空のアイテムの時は後の入れ替え処理をしないようにする */
                      if (widget.children[index] == null){
                        setState(() => flg = false);
                      } 
                      if(flg){
                        setState(() {
                          /** 付箋をめくる */
                          mekuriflgs[index] = true;
                          /** 指の位置によってtopとleftを補正 */
                          startPosition = details.localPosition;
                          top = fixedPosition[index].dy + details.localPosition.dy - startPosition.dy;
                          left = fixedPosition[index].dx + details.localPosition.dx - startPosition.dx;
                          /** プレビュー用アイテムに移動するアイテムを入れて */
                          previewItem = widget.children[index]!;
                          previewColor = widget.colors[index];
                          /** 元の場所は見えないようにする */
                          widget.children[index] = null;
                        });
                      }
                    },
                    onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
                      if(flg){
                        setState(() {
                          top = fixedPosition[index].dy + details.localPosition.dy - startPosition.dy;
                          left = fixedPosition[index].dx + details.localPosition.dx - startPosition.dx;
                        });
                      }
                    },
                    onLongPressEnd: (LongPressEndDetails details) async {
                      /** アイテムが空じゃなかったら入れ替え */
                      if (flg) {
                        /** スタート時からの差分 */
                        double dx = details.localPosition.dx;
                        double dy = details.localPosition.dy;
                        /** なんかマイナスの時は+gredSizeされるっぽいので補正 */
                        dx -= dx < 0 ? gredSize : 0;
                        dy -= dy < 0 ? gredSize : 0;
                        /** 移動先index算出 */
                        int moved = widget.crossAxisCount * (dy ~/ gredSize) + (dx ~/ gredSize); //差分
                        moved += index; // 移動先index
                        setState(() {
                          /** アイテム配列サイズを超えるなら拡張 */
                          if (moved >= widget.children.length) {
                            for (var i = widget.children.length; i <= moved; i++) {
                              widget.children = listAddAt(widget.children, i, null) as List<Widget?>;
                              widget.colors = listAddAt(widget.colors, i, null) as List<HusenColor>;
                              widget.keys = listAddAt(widget.keys, i, null);
                              fixedPosition = listAddAt(fixedPosition, i, Offset((i % widget.crossAxisCount * gredSize) + i % widget.crossAxisCount * widget.axisSpacing, (i ~/ widget.crossAxisCount * gredSize) + i ~/ widget.crossAxisCount * widget.axisSpacing)) as List<Offset>;
                              mekuriflgs = listAddAt(mekuriflgs, i, false) as List<bool>;
                            }
                          }
                          /** 入れ替え先の付箋をめくる */
                          mekuriflgs[moved] = true;
                          /** 入れ替え */
                          var cData = widget.keys[index];
                          widget.children[index] = widget.children[moved];
                          widget.colors[index] = widget.colors[moved];
                          widget.keys[index] = widget.keys[moved];
                          widget.children[moved] = previewItem;
                          widget.colors[moved] = previewColor!;
                          widget.keys[moved] = cData;
                          /** 末尾の空白を消す */
                          widget.children = endNullDelete(widget.children) as List<Widget?>;
                          widget.colors = endNullDelete(widget.colors) as List<HusenColor>;
                          widget.keys = endNullDelete(widget.keys);
                          /** プレビュー用アイテムを画面外に飛ばす */
                          previewItem = null;
                          previewColor = null;
                          top = -gredSize;
                          left = -gredSize;
                          /** 元の場所付箋のめくりを戻す */
                          mekuriflgs[index] = false;
                        });
                        /** 一瞬待ってから付箋のめくりを戻す */
                        await new Future.delayed(new Duration(milliseconds: 110));
                        setState(() => mekuriflgs[moved] = false);
                        /** keysを親に返す */
                        widget.onReorder(widget.keys);
                      }
                    },
                    /** アイテム
                     *  うっかりnullを直で突っ込むと無限のサイズが与えられました的なのが出るから
                     *  Containerで囲む */
                    child: Container(
                      width: gredSize, height: gredSize, 
                      color: Colors.transparent,
                      child: husenOrNull(widget.children[index], mekuriflgs[index], widget.colors[index]!)
                    ),
                  )
                );
              })),
              /** プレビュー用アイテム */
              Positioned(
                top: top,
                left: left,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: previewItem == null ? null : [const BoxShadow(
                      color: Colors.black12, 
                      blurRadius: 10.0, 
                      spreadRadius: 1.0, 
                      offset: Offset(5, 5))
                    ],), 
                  child: HusenContainer(
                    color: previewColor == null ? null : previewColor!.color,
                    backSideColor: previewColor == null ? null : previewColor!.backSideColor,
                    mekuriFlg: true,
                    child: Container(width: gredSize, height: gredSize, child: previewItem),
                  )
                ),
              ),
            ]),
          )
        );
    });
  }

  Widget? husenOrNull(Widget? item, bool mekuriflgs, HusenColor color){
    if(item == null){
      return null;
    }else{
      return HusenContainer(
        color: color.color,
        backSideColor: color.backSideColor,
        mekuriFlg: mekuriflgs,
        child: Container(width: gredSize, height: gredSize, child: item),
      );
    }
  }
  List<dynamic> listAddAt(List<dynamic> list, int index, dynamic item) {
    /** アイテム配列サイズを超えるならnullを入れて拡張 */
    if (index >= list.length) {
      for (int i = list.length; i <= index; i++) {
        list.add(null);
      }
    }
    list[index] = item;
    return list;
  }
  List<dynamic> endNullDelete(List<dynamic> list) {
    /** 末尾のnullを削除 */
    for (int i = list.length - 1; i >= 0; i--) {
      if (list[i] != null) {
        break;
      }
      list.removeAt(i);
    }
    return list;
  }
}
