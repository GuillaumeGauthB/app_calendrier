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
      _list.add(
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
        ),
      ) ;
    }
  }

  Widget getSubDataChecklist(parentItem, int index) {
    List widgetsToSend = [];

    if(openedItemId != null && openedItemId == parentItem['id']){
      currentHeight = heightToOpen;
    } else {
      currentHeight = 0;
    }

    listChildCheckbox = parentItem.keys.where((el) => el.toString().contains('checkbox') && !el.toString().contains('completed')).toList();
    listChildCheckbox!.sort((a,b) {
      if(a.length != b.length){
        return a.length.compareTo(b.length);
      }
      return a.compareTo(b);
    });

    for(var i in listChildCheckbox!){

      currentTextDecoration = TextDecoration.none;

      if(currentHeight == heightToOpen){
        if((parentItem['${i}_completed'].runtimeType == bool && parentItem['${i}_completed']) || (parentItem['${i}_completed'].runtimeType == String && parentItem['${i}_completed'].toLowerCase == 'true')){
          currentTextDecoration = TextDecoration.lineThrough;
        }
      }
      widgetsToSend.add(
          AnimatedContainer(
              height: currentHeight,
              duration: const Duration(milliseconds: 100),

              child: GestureDetector(
                onTap: () {
                  setState(() {
                    parentItem['${i}_completed'] = !parentItem['${i}_completed'];
                    FileUtils.modifyFile(parentItem, fileName: 'checklists.json', mode: 'modifier', id: parentItem['id'], collection: 'Checklists');
                    setUpList;
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

    if(currentHeight != 0){
      isVisible = true;
    }

    widgetsToSend.add(
        AnimatedContainer(
            height: currentHeight == 0 ? 0 : 60,
            duration: const Duration(milliseconds: 150),
            onEnd: () {
              if(currentHeight == 0){
                setState(() {
                  isVisible = false;
                });
              }
            },
            child: Visibility(
              visible: isVisible,
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
                          FileUtils.modifyFile({},collection: 'Checklists', fileName: 'checklists.json', mode: 'supprimer', id: parentItem['id']);
                          print(listeChecklists.indexWhere((element) => element['id'] == parentItem['id']));
                          _list.removeAt(listeChecklists.indexWhere((element) => element['id'] == parentItem['id']));
                          lengthList--;
                          _listKey.currentState?.removeItem(
                            listeChecklists.indexWhere((element) => element['id'] == parentItem['id']),
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
                                                hintText: parentItem['name'],
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
                          listeChecklists.removeWhere((e) => e['id'] == parentItem['id']);
                          _listOri.removeWhere((element) => element['id'] == parentItem['id']);
                          _selectedItem = null;
                          openedItemId = null;
                          //lengthList--;
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
        )
    );

    isVisible = false;

    Widget widgetToSend = Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
        ),
        child: Column(
          children: [
            ...widgetsToSend,
          ],
        )
    );

    return widgetToSend;
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
                  behavior: HitTestBehavior.deferToChild,
                  onTap: () {
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
