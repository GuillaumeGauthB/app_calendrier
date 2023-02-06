import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/widgets/modify_event.dart';
import './refresh_data.dart';
import '../res/values.dart';
import './calendar.dart';
import 'package:get/get.dart';

import 'add_event.dart';
// import 'package:get/get.dart';

class CalendarBase extends StatelessWidget {
  const CalendarBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // an app bar at the top
      appBar: AppBar(
        // style of text set in text element
        title: Text(
          'Calendrier',
          style: TextStyle(color: colors["backgroundColor"],
              fontSize: 25),
        ),
        actions: const [
          RefreshData(),
        ],
        //backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: Calendar(),//Get.put<Calendar>(Calendar()),

      /*bottomNavigationBar: BottomAppBar(
        // style of text set in text element
        child: Text('Bottom app bar')

        //backgroundColor: Theme.of(context).colorScheme.primary,
      ),*/
    );
  }
}

class BoutonAjouterEvenement extends StatelessWidget {
  const BoutonAjouterEvenement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('test refresh calendrier');
    //print('calendar ${calendar.getAmountOfDays}');
    return GestureDetector(
      onTap: () {
        //setState(() {
        showModalBottomSheet(
            enableDrag: true,
            isScrollControlled: true,
            context: context,
            builder: (context) {
              /**
               * Class that adds event
               */
              return Container(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child:AddEvent({
                    "day": 1,
                    "month": 1,
                    "year": 2023
                  })
              );
            }
        );//.whenComplete(() => {setState(() {}), print('testtstsestestetestes')});
      },

      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.all(Radius.circular(35)),
        ),

        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Ajouter un évènement'),
              Icon(
                Icons.add,
                color: Colors.black,
                size: 25.0,
              ),
            ]
        ),
      ),
    );
  }
}


class ModifyEventBase extends StatelessWidget {
  const ModifyEventBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // style of text set in text element
        title: Text(
          'Calendrier',
          style: TextStyle(color: colors["backgroundColor"],
              fontSize: 25),
        ),
      ),
      body: ModifyEvent(Get.arguments),
    );
  }
}

