import 'package:flutter/material.dart';
import 'package:tag_memo/data/sqlite/sqlite.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({
    required this.orderId,
    Key key = const Key(''),
  }) : super(key: key);
  final int orderId;

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('付箋を削除しますか？', style: TextStyle(color: Colors.black54)),
                    Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(
                        top: deviceHeight * 0.35 * 0.3, 
                        bottom: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ボタン領域
                          TextButton(
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromWidth(110),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5),),
                            ),
                            child: const Text('キャンセル', style: TextStyle(color: Colors.white)),
                            onPressed: () => Navigator.pop(context, 'cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromWidth(110),
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5),),
                            ),
                            child: const Text('削除', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              deleteMemoOrder(widget.orderId).then((_) => Navigator.of(context).pop());
                              // Navigator.of(context).pop();
                            },
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
