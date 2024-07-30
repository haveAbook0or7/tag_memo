import 'package:flutter/material.dart';


class CustomText extends StatelessWidget {
  String data;
  TextStyle style;
  TextAlign? textAlign;
  TextDirection? textDirection;
  TextOverflow overflow;
  int? maxLines;
  
  CustomText(
    this.data,{
    required this.style,
    this.textAlign,
    this.textDirection,
    required this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final widgetHeight = constraints.maxHeight;
      final widgetWidth = constraints.maxWidth;
      final datas = data.split('\n');
      maxLines = maxLines ?? datas.length;

        return Container(
          height: widgetHeight, width: widgetWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: datas.length <= maxLines! ?
            List.generate(datas.length, (index) {
              return Text(datas[index], overflow: overflow, style: style, textAlign: textAlign, textDirection: textDirection);
            }) : 
            List.generate(maxLines!+1, (index) {
              if(index == maxLines){
                return Text('...', style: style, textAlign: textAlign, textDirection: textDirection);
              }
              return Text(datas[index], overflow: overflow, style: style, textAlign: textAlign, textDirection: textDirection);
            }),
          ),
        );
    });
  }
}
