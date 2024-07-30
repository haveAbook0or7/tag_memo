import 'package:flutter/material.dart';
import 'package:tag_memo/customWidget/customTile.dart';


class DropdownTile extends StatelessWidget {
  const DropdownTile({
    Key? key, 
    this.title = '',
    this.value,
    this.items = const <String>[],
    required this.onChanged,
  }) : super(key: key);
  final String title;
  final String? value;
  final List<String> items;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {

      return LayoutBuilder(builder: (context, constraints) {
        return CustomTile(
          title: Text(title, style: const TextStyle(fontSize: 16),),
          trailing: DropdownButton<String>(
            icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.secondary,),
            iconSize: 22,
            underline: Container(height: 2, color: Theme.of(context).colorScheme.secondary,),
            value: value,
            items: items.map<DropdownMenuItem<String>>((String value) {
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
      },);
  }
}
