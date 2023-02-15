import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/res/checklists.dart';
import 'package:flutter_calendrier_2/utils/file_utils.dart';
import 'package:flutter_calendrier_2/widgets/checkbox_item.dart';

import '../utils/lists_manipulation.dart';
import 'add_checklist.dart';

class ListCheckmarks extends StatefulWidget {
  const ListCheckmarks({Key? key}) : super(key: key);

  @override
  State<ListCheckmarks> createState() => _ListCheckmarksState();
}

class _ListCheckmarksState extends State<ListCheckmarks> {
  //final GlobalKey<SliverAnimatedListState> _listKey =
  //                              GlobalKey<SliverAnimatedListState>();
  final _listKey = GlobalKey<AnimatedListState>();
  late List _listOri = ListsManipulation.ListChecklists;
  List _list = [];
  Widget? _selectedItem;
  Widget? _clickedItem;

  int currently_open = -1;
/*
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return CheckboxItem(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }*/

  void ModifyChecklist({id}) {
    showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddChecklist();
      },
    ).whenComplete(() => {setState(() { _list = ListsManipulation.ListChecklists;})});
  }

  @override
  void initState() {
    super.initState();
    for(var i in _listOri){
      _list.add(
          Text('${i['name']}', style: TextStyle(fontSize: 20),),
      ) ;
    }

  }

  Widget getSubDataChecklist(parentItem, index) {
    List widgetsToSend = [];
    for(var i in parentItem.keys.where((el) => el.toString().contains('checkbox') && !el.toString().contains('completed')).toList().reversed){
      widgetsToSend.add(
          CheckboxListTile(
            title: Text('${parentItem[i]}', style: TextStyle(color: Colors.white), textWidthBasis: TextWidthBasis.longestLine),
            value: parentItem['${i}_completed'],
            onChanged: (bool? value) {
              parentItem['${i}_completed'] = value!;
              setState(() {
                _list[index] = getSubDataChecklist(parentItem, index);
              });
            },
          )
      );
    }

    Widget widgetToSend = Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          children: [...widgetsToSend],
        )
    );

    return widgetToSend;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _list.length,
            itemBuilder: (BuildContext context, int index, Animation<double> animation) {
              return GestureDetector(
                onTap: () {
                  if(_listOri[index] != null){

                    if(_selectedItem == null){
                      _clickedItem = _list[index];
                      var parentItem = _listOri[_list.indexOf(_clickedItem)];

                      Widget widgetToSend = getSubDataChecklist(parentItem, _list.indexOf(_clickedItem)+1);

                      _list.insert(_list.indexOf(_clickedItem)+1, widgetToSend);
                      _listKey.currentState?.insertItem(_list.indexOf(_clickedItem)+1);
                      _selectedItem = _list[_list.indexOf(_clickedItem)+1];
                    } else {
                      print(_list.indexOf(_clickedItem));
                      _clickedItem = _list[index];
                      if(_clickedItem == _list[index]){
                        int indexDel = _list.indexOf(_selectedItem);
                        _list.removeAt(indexDel);
                        _listKey.currentState?.removeItem(indexDel, (context, animation)  {return Placeholder();});

                        /*if(_list.indexOf(_clickedItem)+1 != _list.indexOf(_selectedItem)){
                          _clickedItem = _list[index];
                          var parentItem = _listOri[_list.indexOf(_clickedItem)];

                          Widget widgetToSend = getSubDataChecklist(parentItem, _list.indexOf(_clickedItem)+1);

                          _list.insert(_list.indexOf(_clickedItem)+1, widgetToSend);
                          _listKey.currentState?.insertItem(_list.indexOf(_clickedItem)+1);
                          _selectedItem = _list[_list.indexOf(_clickedItem)+1];
                        } else {*/
                          _selectedItem = null;
                        //}
                      }
                    }
                  }


                },
                child: _list[index],
              );
            },

          ),
        ),
        ElevatedButton(
          onPressed: ModifyChecklist,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Ajouter une liste'),
              Icon(Icons.add),
            ],
          ),
        )
      ],
    );
  }
}
