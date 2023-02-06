import 'package:flutter/material.dart';
import '../res/values.dart';

// Single day component
class day extends StatelessWidget {
  int currentDay, // le jour a imprimer
      dayClicked,
      currentMonthNum,
      currentYear; // le jour a imprimer
  bool currentMonth; // le mois a imprimer

  late Color textColor,
        bgColor;

  DateTime now = DateTime.now();

  //const day({Key? key, required int currentDay}) : super(key: key);
  day(this.currentDay, this.currentMonthNum, this.currentYear, this.currentMonth, this.dayClicked);

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;

    double widthDay = (widthScreen / 7) - 2;

    textColor = colors["pastMonth"];
    bgColor = colors["backgroundColor"];

    if(currentMonth == true){
      textColor = colors["currentMonth"];

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
    return Container(
      width: widthDay,
      height: widthDay,
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),

      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(100)),
      ),

      child: Center(
        child: Text(
          currentDay.toString(),
          style: TextStyle(color: textColor),
          textAlign: TextAlign.center,
        ),
      ) ,
    );
  }
}


