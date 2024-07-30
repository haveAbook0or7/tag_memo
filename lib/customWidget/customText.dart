// ignore: file_names
import 'dart:math';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText(
    this.data,
    {
      Key? key, 
      required this.style,
      this.textAlign,
      this.textDirection,
      required this.overflow,
      this.maxLines = 7,
    }
  ) : super(key: key);
  final String data;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextOverflow overflow;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final datas = data.split('\n');

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: 
            List.generate(min(datas.length, maxLines), (index) {
              return Text(
                (index == maxLines-1) ? '...' : datas[index],
                overflow: overflow,
                style: style,
                textAlign: textAlign,
                textDirection: textDirection,
              );
            }),
          ),
        );
    },);
  }
}
