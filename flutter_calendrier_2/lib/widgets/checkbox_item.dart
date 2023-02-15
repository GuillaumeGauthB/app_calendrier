import 'package:flutter/material.dart';

class CheckboxItem extends StatefulWidget {
  const CheckboxItem({
    super.key,
    //this.onTap,
    //this.selected = false,
    //required this.animation,
    required this.item,
    required this.listKey,
    required this.index,
    required this.list
  });

  final Map<String, dynamic> item;
  final listKey;
  final int index;
  final List list;

  @override
  State<CheckboxItem> createState() => _CheckboxItemState(item: item, listKey: listKey, index: index, list: list);
}

class _CheckboxItemState extends State<CheckboxItem> {
  _CheckboxItemState({
    //super.key,
    //this.onTap,
    //this.selected = false,
    //required this.animation,
    required this.item,
    required this.listKey,
    required this.index,
    required this.list
  });

  final Map<String, dynamic> item;
  final GlobalKey<AnimatedListState> listKey;
  final int index;
  final List list;
  List widgetsToSend = [];

  @override
  void initState(){
    super.initState();
    for(var i in item.keys.where((el) => el.toString().contains('checkbox') && !el.toString().contains('completed')).toList().reversed){
      widgetsToSend.add(
          CheckboxListTile(
            title: Text('${item[i]}', style: TextStyle(color: Colors.white), textWidthBasis: TextWidthBasis.longestLine),
            value: item['${i}_completed'],
            onChanged: (bool? value) {
              //setState(() {

              //});
              listKey.currentState?.setState(() {
                print(index);
                list[index] = CheckboxItem(item: item, listKey: listKey, index: index, list: list);
              });
            },
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          children: [...widgetsToSend],
        )
    );
  }
}