import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/res/events.dart';
import '../res/values.dart';

// Single day component
class day extends StatelessWidget {
  int currentDay, // le jour a imprimer
      dayClicked,
      currentMonthNum,
      currentYear; // le jour a imprimer
  bool currentMonth; // le mois a imprimer

  late Color textColor, // la couleur du texte
        bgColor;  // la couleur du background

  late int eventInDay; // nombre d'evenements sur la journee present

  DateTime now = DateTime.now(); // informations de la journee presente

  //const day({Key? key, required int currentDay}) : super(key: key);
  day(this.currentDay, this.currentMonthNum, this.currentYear, this.currentMonth, this.dayClicked);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;

    double widthDay = (widthScreen / 7) - 2;

    textColor = colors["pastMonth"];
    bgColor = Theme.of(context).backgroundColor;

    if(currentMonth == true){
      // textColor = colors["currentMonth"];
      textColor = Theme.of(context).colorScheme.onBackground;

      if(now.day - 1 == currentDay &&
          currentMonthNum == now.month &&
          currentYear == now.year
      ){
        textColor = colors["presentDayText"];
        bgColor = colors["presentDayBackground"];
      }

    }

    if(dayClicked == currentDay){
      textColor = Theme.of(context).colorScheme.onPrimary;
      bgColor = Theme.of(context).colorScheme.primary;
    }

    currentDay++;

    eventInDay = tableaux_evenements.where((o) => o['day'] == currentDay && o['month'] == currentMonthNum && o['year'] == currentYear && currentMonth).length;

    return Container(
      width: widthDay,
      height: widthDay,
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),

      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(100)),
      ),

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(''),
            Text(
              currentDay.toString(),
              style: TextStyle(color: textColor),
              textAlign: TextAlign.center,
            ),
            if(eventInDay > 0)
              Container(
                width: widthDay / 5,
                height: widthDay / 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey,
                ),
              )
            else
              Text(''),
          ],
        )
      ) ,
    );
  }
}