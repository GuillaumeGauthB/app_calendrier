import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/res/events.dart';
import 'package:flutter_calendrier_2/utils/lists_manipulation.dart';
import '../res/values.dart';

// Single day component
class day extends StatelessWidget {
  int currentDay, // le jour a imprimer
      dayClicked,
      currentMonthNum,
      currentYear; // le jour a imprimer
  bool currentMonth; // le mois a imprimer

  late Color textColor, // la couleur du texte
        bgColor,        // la couleur du background
        circleColor,    // la couleur du cercle
        circleBorderColor;// la couleur de la bordure du cercle

  late Map<String, bool> eventInDay; // nombre d'evenements sur la journee present

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
      bgColor = Theme.of(context).colorScheme.secondary;
    }

    currentDay++;

    //eventInDay = tableaux_evenements.where((o) => o['day'] == currentDay && o['month'] == currentMonthNum && o['year'] == currentYear && currentMonth).length;
    eventInDay = ListsManipulation.GetEventTypes(
        list: ListsManipulation.ListEventSchedule(day: currentDay, month: currentMonthNum, year: currentYear),
        condition: currentMonth
    );

    if(eventInDay['event']!){
      circleColor = Colors.grey;
    } else {
      circleColor = Colors.transparent;
    }

    if(eventInDay['schedule']!){
      circleBorderColor = Colors.red;
    } else {
      circleBorderColor = Colors.transparent;
    }

    //print(eventInDay);

    return FractionallySizedBox(
      // aspectRatio: 1,
      widthFactor: 1 / 7,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          // width: widthDay,
          // height: widthDay,
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),

          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(100)),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: widthDay / 5,
                height: widthDay / 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.transparent,
                ),
              ),
              Text(
                currentDay.toString(),
                style: TextStyle(color: textColor),
              ),
              Container(
                width: widthDay / 5,
                height: widthDay / 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: circleColor,
                  border: Border.all(color: circleBorderColor)
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}