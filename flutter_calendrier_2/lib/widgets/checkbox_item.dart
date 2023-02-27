import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/res/checklists.dart';

class CheckboxItem extends StatefulWidget {
  const CheckboxItem({
    Key? key,
    required this.item,
    this.openedItemId,
    this.heightToOpen,
    this.removeElement,
    this.modifyElement,
    this.checkChild,
    this.showAsWhole
  }) : super(key: key);

  final Map<String, dynamic> item;
  final int? openedItemId;
  final double? heightToOpen;
  final Future<Null> Function()? removeElement;
  final VoidCallback? modifyElement;
  final Function(String)? checkChild;
  final bool? showAsWhole;

  @override
  State<CheckboxItem> createState() => _CheckboxItemState(
      item: item,
      openedItemId: openedItemId,
      heightToOpen: heightToOpen,
      removeElement: removeElement,
      modifyElement: modifyElement,
      checkChild: checkChild,
      showAsWhole: showAsWhole,
  );
}

class _CheckboxItemState extends State<CheckboxItem> {
  _CheckboxItemState({
    Key? key,
    required this.item,
    this.openedItemId,
    this.removeElement,
    this.heightToOpen,
    this.modifyElement,
    this.checkChild,
    this.showAsWhole,
  });


  final Map<String, dynamic> item;
  final int? openedItemId;
  final double? heightToOpen;
  final Future<Null> Function()? removeElement;
  final VoidCallback? modifyElement;
  final Function(String)? checkChild;
  final bool? showAsWhole;

  BoxDecoration? itemDecoration;

  List? listChildCheckbox;
  bool isVisible = false;
  double currentHeight = 0;
  late TextDecoration currentTextDecoration;

  @override
  Widget build(BuildContext context) {
    //print('enfant ${widget.openedItemId != null && widget.openedItemId == widget.item['id']}');

    if(showAsWhole == true){
      itemDecoration = BoxDecoration(
        color: Theme.of(context).primaryColor,
      );
    } else {
      itemDecoration = const BoxDecoration(
        color: Colors.transparent,
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: itemDecoration ?? const BoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.item['name']}', style: TextStyle(fontSize: 20),),
              if(showAsWhole == null || !showAsWhole!)
                Icon(widget.openedItemId != null && widget.openedItemId == widget.item['id'] ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down)
            ],
          ),
        ),
        getSubDataChecklist(widget.item),
      ],
    );
  }

  Widget getSubDataChecklist(parentItem) {
    List widgetsToSend = [];

    if(widget.openedItemId != null && widget.openedItemId == parentItem['id']){
      currentHeight = widget.heightToOpen!;
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

      if(currentHeight == widget.heightToOpen || (showAsWhole == null || showAsWhole!)){
        if((parentItem['${i}_completed'].runtimeType == bool && parentItem['${i}_completed']) || (parentItem['${i}_completed'].runtimeType == String && parentItem['${i}_completed'].toLowerCase == 'true')){
          currentTextDecoration = TextDecoration.lineThrough;
        }
      }
      widgetsToSend.add(
          AnimatedContainer(
              height: (showAsWhole == null || !showAsWhole!) ? currentHeight : widget.heightToOpen,
              duration: const Duration(milliseconds: 100),

              child: GestureDetector(
                onTap: () {
                  if(checkChild != null){
                    checkChild!(i);
                  }
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
              visible: showAsWhole == null || showAsWhole == false ? isVisible : false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: modifyElement ?? () {},

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
                    onPressed: removeElement ?? () {},

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
}
