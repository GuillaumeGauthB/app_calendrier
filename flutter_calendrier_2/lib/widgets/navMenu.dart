import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavMenu extends StatelessWidget {
  //const NavMenu({Key? key}) : super(key: key);

  final List<String> listLiens = [
    'calendrier',
    'settings'
  ];
  int index = 0;
  Map getParam = {};

  @override
  Widget build(BuildContext context) {
    if(Get.arguments.runtimeType != Null){
      getParam = Get.arguments;
      print(getParam['pageIndex']);
      if(getParam['pageIndex'].runtimeType == int){
        index = getParam['pageIndex'];
      }
    }

    return BottomNavigationBar(
      onTap: (int pos) {
        //print(listLiens[pos]);
        Get.offAndToNamed('/${listLiens[pos]}', arguments: { 'pageIndex': pos });
        //Get.toNamed("/calendrier");
      },
      currentIndex: index,
      items: const [
        BottomNavigationBarItem(
          label: 'Calendrier',
          icon: Icon(Icons.calendar_month),
        ),
        BottomNavigationBarItem(
          label: 'Réglages',
          icon: Icon(Icons.settings),
        )
      ],
    );
  }
}
