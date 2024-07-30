import 'package:flutter/material.dart';


class CustomAlert extends StatefulWidget {
  const CustomAlert({
    required this.msgtext,
    Key key = const Key(''),
  }) : super(key: key);
  final String msgtext;

  @override
  _CustomAlertState createState() => _CustomAlertState();
}

class _CustomAlertState extends State<CustomAlert> {
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
                      child: TextButton(
                        style: TextButton.styleFrom(
                          fixedSize: const Size.fromWidth(110),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5),),
                        ),
                        child: const Text('閉じる', style: TextStyle(color: Colors.white)),
                        onPressed: () => Navigator.of(context).pop(),
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
