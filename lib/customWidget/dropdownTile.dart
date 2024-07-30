import 'package:flutter/material.dart';

import 'customTile.dart';

class DropdownTile extends StatelessWidget {
  
  DropdownTile({
    this.title = '',
    this.value,
    this.items,
    required void Function(String) onChanged,
  });
  String title;
  late String? value;
  late List<String>? items;
  late void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    items = items ?? [];
    onChanged = onChanged ?? (newValue){};

      return LayoutBuilder(builder: (context, constraints) {
        return CustomTile(
          title: Text(title!, style: const TextStyle(fontSize: 16),),
          trailing: DropdownButton<String>(
            icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).primaryColor,),//TODO accent
            iconSize: 22,
            underline: Container(
              height: 2,
              color: Theme.of(context).primaryColor,//TODO accent
            ),
            value: value,
            items: items?.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              onChanged(newValue!);
            },
          ),
        );
      });
  }
}
