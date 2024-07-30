// ignore: file_names
import 'package:flutter/material.dart';

class HusenColor {
  HusenColor({
    required this.color, 
    required this.backSideColor,
  });
  final Color color;
  final Color backSideColor;

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'backSideColor': backSideColor,
    };
  }
  @override
  String toString() {
    return 'HusenColor{color: $color, backSideColor: $backSideColor,}';
  }
}


class HusenContainer extends StatelessWidget {
  HusenContainer({
    Key? key, 
    this.mekuriFlg,
    this.height = 300,
    this.width = 300,
    Widget? child,
    HusenColor? husencolor,
  }) : 
    husencolor = husencolor ?? HusenColor(color: Colors.greenAccent, backSideColor: Colors.green), 
    child = child ?? SizedBox(width: width, height: height,),
    super(key: key);
  final bool? mekuriFlg;
  final double height;
  final double width;
  final Widget child;
  final HusenColor husencolor;

  @override
  Widget build(BuildContext context) {

    return CustomPaint(
      size: Size(width, height),
      painter: HusenPainter(
        mekuriFlg: mekuriFlg ?? false,
        husencolor: husencolor,
      ),
      child: child,
    );
  }
}

class HusenPainter extends CustomPainter {
  HusenPainter({ 
    this.mekuriFlg = false,
    required this.husencolor,
  });
  final bool mekuriFlg;
  final HusenColor husencolor;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height / 6 * 5)
      ..lineTo(size.width / 6 * 5, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, 0);
    var paint = Paint()
      ..color = husencolor.color;

    canvas.drawPath(path, paint);

    if(mekuriFlg){
      path = Path()
        ..moveTo(size.width / 6 * 5, size.height / 6 * 5)
        ..lineTo(size.width, size.height / 6 * 5)
        ..lineTo(size.width / 6 * 5, size.height)
        ..lineTo(size.width / 6 * 5, size.height / 6 * 5);
      paint = Paint()
        ..color = husencolor.backSideColor;
    }else{
      path = Path()
        ..moveTo(size.width, size.height)
        ..lineTo(size.width, size.height / 6 * 5)
        ..lineTo(size.width / 6 * 5, size.height)
        ..lineTo(size.width, size.height);
    }

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
