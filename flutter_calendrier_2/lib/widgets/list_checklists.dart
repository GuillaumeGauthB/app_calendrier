import 'package:animations/animations.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
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
  double heightToOpen = 0;
  bool boolVisibility = false;
  late TextDecoration currentTextDecoration;
  double currentHeight = 0;
  int? openedItemId;

  void ModifyChecklist({id}) {
    showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddChecklist(id: id);
      },
    ).whenComplete(() => { _listOri = ListsManipulation.ListChecklists, setUpList, setState(() { })});
  }

  @override
  void initState() {
    super.initState();

  }

  Widget getSubDataChecklist(parentItem, int index) {
    List widgetsToSend = [];

    if(openedItemId != null && openedItemId == parentItem['id']){
      currentHeight = heightToOpen;
    } else {
      currentHeight = 0;
    }

    for(var i in parentItem.keys.where((el) => el.toString().contains('checkbox') && !el.toString().contains('completed')).toList()){

      currentTextDecoration = TextDecoration.none;

      if(currentHeight == heightToOpen){
        if((parentItem['${i}_completed'].runtimeType == bool && parentItem['${i}_completed']) || (parentItem['${i}_completed'].runtimeType == String && parentItem['${i}_completed'].toLowerCase == 'true')){
          currentTextDecoration = TextDecoration.lineThrough;
        }
      }
      widgetsToSend.add(
          AnimatedContainer(
            height: currentHeight,
            duration: const Duration(milliseconds: 300),

            child: GestureDetector(
              onTap: () {
                setState(() {
                  parentItem['${i}_completed'] = !parentItem['${i}_completed'];
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Text('${parentItem[i]}', style: TextStyle(color: Colors.white, decoration: currentTextDecoration), textWidthBasis: TextWidthBasis.longestLine),
              ),
            )
          )
      );
    }

    if(openedItemId != null && openedItemId == parentItem['id']){
      widgetsToSend.add(
        AnimatedContainer(
          height: 60,
          duration: const Duration(milliseconds: 300),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  //setState(() {
                  ModifyChecklist(id: parentItem['id']);
                },

                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.edit,
                        size: 25.0,
                      ),
                    ]
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if(await confirm(
                      context,
                      title: const Text('Supprimer'),
                      content: const Text('Êtes-vous certain de vouloir supprimer cette liste?'),
                      textOK: const Text('Oui'),
                      textCancel: const Text("Non")
                    )
                  ){
                    _listKey.currentState?.setState(() {
                      listeChecklists.removeWhere((e) => e['id'] == parentItem['id']);
                      FileUtils.modifyFile({},collection: 'Checklists', fileName: 'checklists.json', mode: 'supprimer', id: parentItem['id']);
                      _list.removeAt(index);
                      _listOri.removeWhere((element) => element['id'] == parentItem['id']);
                      _selectedItem = null;
                      openedItemId = null;

                    });
                  }
                },

                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.delete_forever,
                        size: 25.0,
                      ),
                    ]
                ),
              ),
            ],
          ),
        )
      );
    }


    Widget widgetToSend = Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          children: [
            ...widgetsToSend,
          ],
        )
    );

    return widgetToSend;
  }

  get setUpList {
    _list = [];
    for(var i in _listOri){
      _list.add(
        Column(
          children: [
            Text('${i['name']}', style: TextStyle(fontSize: 20),),
            getSubDataChecklist(i, _list.length),
          ],
        )
      ) ;
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setUpList;
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
                      setState(() {
                        print(_listOri[index]);
                        heightToOpen = 20;
                        boolVisibility = true;
                        openedItemId = _listOri[index]['id'];
                        setUpList;
                      });
                      _selectedItem = _list[_list.indexOf(_clickedItem)+1];
                    } else {
                      setState(() {
                        heightToOpen = 0;
                        boolVisibility = false;
                        openedItemId = null;
                        setUpList;
                      });
                      _selectedItem = null;
                    }
                    //print(index);
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
