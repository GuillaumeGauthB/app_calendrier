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
  bool isVisible = false;
  List<String>? listChildCheckbox;
  late int lengthList;

  void ModifyChecklist({id}) {
    showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddChecklist(id: id);
      },
    ).whenComplete(() => {
      setState(() {
        _listOri = ListsManipulation.ListChecklists;
        setUpList;
        _listKey.currentState?.insertItem(_listOri.length-1);
      })
    });
  }

  @override
  void initState() {
    super.initState();

  }

  get setUpList {
    _list = [];
    lengthList = listeChecklists.length;
    for(var i in _listOri){
      //print(openedItemId);
      _list.add(
        CheckboxItem(
          item: i,
          openedItemId: openedItemId,
          heightToOpen: heightToOpen,
          removeElement: () async {
            if(await confirm(
                  context,
                  title: const Text('Supprimer'),
                  content: const Text('Êtes-vous certain de vouloir supprimer cette liste?'),
                  textOK: const Text('Oui'),
                  textCancel: const Text("Non")
              )
            ){
              _listKey.currentState?.setState(() {
                FileUtils.modifyFile({},collection: 'Checklists', fileName: 'checklists.json', mode: 'supprimer', id: i['id']);
                _list.removeAt(listeChecklists.indexWhere((element) => element['id'] == i['id']));
                lengthList--;
                _listKey.currentState?.removeItem(
                    listeChecklists.indexWhere((element) => element['id'] == i['id']),
                        (context, animation){

                      // prit de :: https://github.com/flutter/flutter/issues/42079
                      return SizeTransition(
                        sizeFactor: animation.drive(Tween(begin: 0, end: 1)),
                        axis: Axis.vertical,
                        child: FadeTransition(
                          opacity: animation.drive(Tween(begin: 0, end: 1)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      fillColor: Colors.grey[300],
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                                      disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                                      hintText: i['name'],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      );
                    }
                );
                listeChecklists.removeWhere((e) => e['id'] == i['id']);
                _listOri.removeWhere((element) => element['id'] == i['id']);
                _selectedItem = null;
                openedItemId = null;
                //lengthList--;
              });
            }
          },
          modifyElement: () => {
            ModifyChecklist(id: i['id'])
          },
          checkChild: (String test) {
            print(test);
            setState(() {
              i['${test}_completed'] = !i['${test}_completed'];
              FileUtils.modifyFile(i, fileName: 'checklists.json', mode: 'modifier', id: i['id'], collection: 'Checklists');
              setUpList;
            });
          },
        )
        /*
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                //border: BorderDirectional(bottom: BorderSide(color: Colors.grey, width: 1)),
                color: /*_listOri.indexOf(i) % 2 == 1 ? Colors.grey : */Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${i['name']}', style: TextStyle(fontSize: 20),),
                  Icon(openedItemId != null && openedItemId == i['id'] ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down)
                ],
              ),
            ),
            getSubDataChecklist(i, lengthList),
          ],
        ),*/
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
    return ColoredBox(
      color: Theme.of(context).backgroundColor,
      child: Column(
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
              initialItemCount: lengthList,
              itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                print(lengthList);
                /*if(index > lengthList-1){
                  return Placeholder();
                }*/
                return GestureDetector(
                  onTap: () {
                    print('parent ${openedItemId}');
                    if(_listOri[index] != null){
                      if(_selectedItem == null){
                        setState(() {
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
      ),
    );
  }
}
