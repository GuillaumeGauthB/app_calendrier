import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavMenu extends StatelessWidget {
  //const NavMenu({Key? key}) : super(key: key);

  // liste contenant les liens du site
  final List<String> listLiens = [
    'calendrier',
    'checklists',
    'settings'
  ];
  int index = 0; // position dans les liens
  Map getParam = {}; // donnees GET de la page

  @override
  Widget build(BuildContext context) {

    // si nous avons des valeurs GET et que celles si contiennent l'index de la page, le choisir
    if(Get.arguments.runtimeType != Null){
      getParam = Get.arguments;
      if(getParam['pageIndex'].runtimeType == int){
        index = getParam['pageIndex'];
      }
    }

    return Container(
      decoration: const BoxDecoration(
        // border: Border.all(color: Colors.grey)
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0, -2)
          ),
        ]
      ),
      child: BottomNavigationBar(
        // backgroundColor: Theme.of(context).backgroundColor,
        // elevation: 5,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (int pos) {
          Get.offAndToNamed('/${listLiens[pos]}', arguments: { 'pageIndex': pos });
        },
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(
            label: 'Calendrier',
            icon: Icon(
              Icons.calendar_month,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Checklists',
            icon: Icon(
              Icons.check,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Réglages',
            icon: Icon(
              Icons.settings
            ),
          ),
        ],
      ),
    );
  }
}
