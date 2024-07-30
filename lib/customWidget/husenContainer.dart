import 'package:flutter/material.dart';

class HusenColor {

  HusenColor({this.color, this.backSideColor,});
  Color? color;
  Color? backSideColor;

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'backSideColor': backSideColor,
    };
  }
  @override
  String toString() {
    return 'Thokin{color: $color, backSideColor: $backSideColor,}';
  }
}


class HusenContainer extends StatelessWidget {
  HusenContainer({ 
    this.mekuriFlg,
    this.height,
    this.width,
    this.child,
    this.color,
    this.backSideColor,
  });
  bool? mekuriFlg;
  double? height;
  double? width;
  Widget? child;
  Color? color;
  Color? backSideColor;
  @override
  Widget build(BuildContext context) {
    mekuriFlg = mekuriFlg ?? true;
    height ??= 300;
    width ??= 300;
    color ??= Colors.greenAccent;
    backSideColor ??= Colors.green;

    return CustomPaint(
      size: Size(width!, height!),
      painter: HusenPainter(
        mekuriFlg: mekuriFlg!,
        color: color!,
        backSideColor: backSideColor!,
      ),
      child: child,
    );
  }
}

class HusenPainter extends CustomPainter {
  HusenPainter({ 
    this.mekuriFlg,
    this.color,
    this.backSideColor,
  });
  bool? mekuriFlg;
  Color? color;
  Color? backSideColor;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color!;
    var path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height / 6 * 5);
    path.lineTo(size.width / 6 * 5, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);

    if(mekuriFlg!){
      paint = Paint();
      paint.color = backSideColor!;
      path = Path();

      path.moveTo(size.width / 6 * 5, size.height / 6 * 5);
      path.lineTo(size.width, size.height / 6 * 5);
      path.lineTo(size.width / 6 * 5, size.height);
      path.lineTo(size.width / 6 * 5, size.height / 6 * 5);
      canvas.drawPath(path, paint);
    }else{
      paint = Paint();
      paint.color = color!;
      path = Path();

      path.moveTo(size.width, size.height);
      path.lineTo(size.width, size.height / 6 * 5);
      path.lineTo(size.width / 6 * 5, size.height);
      path.lineTo(size.width, size.height);
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
