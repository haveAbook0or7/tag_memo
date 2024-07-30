import 'package:flutter/material.dart';


class CustomDialog extends StatefulWidget {
  const CustomDialog({
    required this.msgtext,
    this.cancelOnPressed,
    this.okOnPressed,
    String? okBtnText,
    Key key = const Key(''),
  }) : 
    okBtnText = okBtnText ?? 'OK',
    super(key: key);
  final String msgtext;
  final void Function()? cancelOnPressed;
  final void Function()? okOnPressed;
  final String okBtnText;

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
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
                    Text(widget.msgtext, style: const TextStyle(color: Colors.black54)),
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
                            onPressed: widget.cancelOnPressed,
                            child: const Text('キャンセル', style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              fixedSize: const Size.fromWidth(110),
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5),),
                            ),
                            onPressed: widget.okOnPressed,
                            child: Text(widget.okBtnText, style: const TextStyle(color: Colors.white)),
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
