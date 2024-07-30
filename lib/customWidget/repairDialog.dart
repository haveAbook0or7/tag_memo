import 'package:flutter/material.dart';
import 'package:tag_memo/data/sqlite/sqlite.dart';


class RepairDialog extends StatefulWidget {
  const RepairDialog({
    required this.memoId,
    Key key = const Key(''),
  }) : super(key: key);
  final String memoId;

  @override
  _RepairDialogState createState() => _RepairDialogState();
}

class _RepairDialogState extends State<RepairDialog> {
  @override
  Widget build(BuildContext context) {

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (context, constraints) {
          final deviceHeight = constraints.maxHeight;
          final deviceWidth = constraints.maxWidth;

            return Container(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                height: deviceHeight * 0.35,
                width: deviceWidth * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(
                        top: 10, 
                        bottom: deviceHeight * 0.35 * 0.15,
                        left: 20,
                        right: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 復元ボタン
                          TextButton(
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromWidth(80),
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5),),
                            ),
                            child: const Text('復元', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              repairMemo(widget.memoId).then((_) => Navigator.of(context).pop());
                            },
                          ),
                          // 完全削除ボタン
                          TextButton(
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromWidth(80),
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5),),
                            ),
                            child: const Text('完全削除', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              deleteForeverMemo(widget.memoId).then((_) => Navigator.of(context).pop());
                            },
                          ),
                        ],
                      ),
                    ),
                    const Text('付箋を復元/完全削除しますか？', style: TextStyle(color: Colors.black54)),
                    Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(
                        top: deviceHeight * 0.35 * 0.15, 
                        bottom: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // キャンセルボタン
                          TextButton(
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromWidth(110),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5),),
                            ),
                            child: const Text('キャンセル', style: TextStyle(color: Colors.white)),
                            onPressed: () => Navigator.pop(context, 'cancel'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
        },),
      );
  }
}
