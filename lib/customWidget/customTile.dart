import 'package:flutter/material.dart';


class CustomTile extends StatelessWidget {
  const CustomTile({
    Key? key, 
    this.title = const SizedBox(),
    required this.trailing,
    this.height = 56.0,
    this.tileColor = Colors.white,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);
  final Widget title;
  final Widget trailing;
  final double height;
  final Color tileColor;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.only( left: 15, right: 15, ),
          height: height,
          color: tileColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[title, trailing],
          ),
        ),
      );
    },);
  }
}
