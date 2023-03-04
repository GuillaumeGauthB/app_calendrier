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
    this.showAsWhole,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  final Map<String, dynamic> item;
  final int? openedItemId;
  final double? heightToOpen;
  final Future<Null> Function()? removeElement;
  final VoidCallback? modifyElement;
  final Function(String)? checkChild;
  final bool? showAsWhole;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  @override
  State<CheckboxItem> createState() => _CheckboxItemState(
      item: item,
      openedItemId: openedItemId,
      heightToOpen: heightToOpen,
      removeElement: removeElement,
      modifyElement: modifyElement,
      checkChild: checkChild,
      showAsWhole: showAsWhole,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor
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
    this.borderRadius,
    this.backgroundColor
  });


  final Map<String, dynamic> item;
  final int? openedItemId;
  final double? heightToOpen;
  final Future<Null> Function()? removeElement;
  final VoidCallback? modifyElement;
  final Function(String)? checkChild;
  final bool? showAsWhole;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  late BoxDecoration itemDecoration;
  late TextStyle itemTextDecoration;

  late Color bgColor,
             fontColor;

  List? listChildCheckbox;
  bool isVisible = false;
  double currentHeight = 0;
  late TextDecoration currentTextDecoration;

  @override
  Widget build(BuildContext context) {
    //print('enfant ${widget.openedItemId != null && widget.openedItemId == widget.item['id']}');

    //fontColor = Theme.of(context).colorScheme.background;
    fontColor = Theme.of(context).primaryColor;
    // bgColor = Theme.of(context).primaryColor;
    bgColor = Colors.transparent;

    itemTextDecoration = TextStyle(
      color: fontColor,
    );

    if(widget.item['completed']){
      itemTextDecoration = itemTextDecoration.copyWith(
        decoration: TextDecoration.lineThrough,
        decorationThickness: 3.5,
        decorationColor: const Color(0xFFdddddd), fontSize: 15
      );
    }

    itemDecoration = BoxDecoration(
      color: bgColor,
    );

    /*if(widget.item['completed']){
      itemDecoration = BoxDecoration(
        //color: Color(0xFF1b1b1b),
        color: backgroundColor,
      );
    }*/

    Widget mainBody = Container(
      padding: const EdgeInsets.all(10),
      decoration: itemDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${widget.item['name']}', style: itemTextDecoration.copyWith(fontSize: 20)),
          if(showAsWhole == null || !showAsWhole!)
            Icon(
              widget.openedItemId != null && widget.openedItemId == widget.item['id'] ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
              color: fontColor,
            )
        ],
      ),
    );

    //Widget bodyToPrint = mainBody;

    if(showAsWhole != null && showAsWhole!){
      mainBody = GestureDetector(
        onTap: () {
          //if(showAsWhole != null && showAsWhole!){
            checkChild!('completed');
          //}
        },
        child: mainBody,
      );
    }


    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Column(
        children: [
          mainBody,


          getSubDataChecklist(widget.item),
          if(showAsWhole == null || !showAsWhole!)
            Divider(

            )
        ],
      ),
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
        if(widget.item['completed'] || (parentItem['${i}_completed'].runtimeType == bool && parentItem['${i}_completed']) || (parentItem['${i}_completed'].runtimeType == String && parentItem['${i}_completed'].toLowerCase == 'true')){
          currentTextDecoration = TextDecoration.lineThrough;
        }
      }
      widgetsToSend.add(
          AnimatedContainer(
              height: (showAsWhole == null || !showAsWhole!) ? currentHeight : widget.heightToOpen,
              duration: Duration(milliseconds: 12 * (listChildCheckbox?.length ?? 0)),

              child: GestureDetector(
                onTap: () {
                  if(checkChild != null){
                    checkChild!(i+'_completed');
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
                  child: Text(
                      parentItem[i].toString(),
                      style: itemTextDecoration.copyWith(
                          decoration: currentTextDecoration,
                          decorationThickness: 3.5,
                          decorationColor: const Color(0xFFdddddd), fontSize: 15
                      ),
                      textWidthBasis: TextWidthBasis.longestLine
                  ),
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
                    onPressed: () {
                      checkChild!('completed');
                    },

                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(
                            Icons.check,
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
            color: bgColor,
            //borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
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
