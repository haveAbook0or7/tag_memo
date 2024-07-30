import 'package:flutter/material.dart';


class CustomTile extends StatelessWidget {
  Widget? title;
  Widget? trailing;
  final double height;
  final Color tileColor;
  Function? onTap;
  Function? onLongPress;
  
  CustomTile({
    this.title,
    required this.trailing,
    this.height = 56.0,
    this.tileColor = Colors.white,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    title = title ?? Container();
    trailing = trailing ?? Container();
    onTap = onTap ?? (){};
    onLongPress = onLongPress ?? (){};

      return LayoutBuilder(builder: (context, constraints) {
        return GestureDetector(
          child: Container(
            padding: const EdgeInsets.only(left: 15,right: 15,),
            height: height,
            color: tileColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                title!,
                trailing!
              ],
            ),
          ),
          onTap: (){
            onTap!();
          },
          onLongPress: (){
            onLongPress!();
          },
        );
      });
  }
}
