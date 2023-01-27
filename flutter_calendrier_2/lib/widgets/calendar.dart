import 'package:flutter/material.dart';
import 'day.dart';
import 'evenements_jour.dart';
import '../res/values.dart';
import 'add_event.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  int _dayClicked = -1;
  int _monthChange = -1;
  int _currentYear = 0;

  late int currentMonth,
          previousMonth,
          nextMonth,
          previousYear,
          nextYear,
          weekdays;

  final DateTime now = DateTime.now();
  late DateTime currentMonthInfo;

  // final List<String> arrayDays =  'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche' ];
   final List<String> arrayDays = [ 'Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa' ];
   final List<String> arrayMonths = [ 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre' ];

  int getAmountOfDays(){
    var amtDays = DateTime(_currentYear, currentMonth + 1, 0);
    return amtDays.day;
  }



  @override
  Widget build(BuildContext context) {
    // TODO rendre la section suivante du code mieux
    if(_monthChange == -1) {
      currentMonth = now.month;
    }else if(_monthChange > 12) {
      currentMonth = 1;
      _currentYear++;
    }else if(_monthChange < 1) {
      currentMonth = 12;
      _currentYear-=1;
    }else{
      currentMonth = _monthChange;
    }

    _monthChange = currentMonth;

    if(currentMonth == 1){
      previousMonth = 12;
      previousYear = _currentYear - 1;
    } else{
      previousMonth = currentMonth;
      previousYear = _currentYear;
    }

    if(currentMonth == 12){
      nextMonth = 1;
      nextYear = _currentYear + 1;
    } else{
      nextMonth = currentMonth + 1;
      nextYear = _currentYear;
    }

    if(_currentYear == 0)
        _currentYear = now.year;

    // TODO jusqu'ici
    //currentMonthInfo = DateTime(_currentYear, currentMonth, 31);
    weekdays = DateTime(_currentYear, currentMonth, 1).weekday;

    // TODO Enlever le debugging
    //print(_dayClicked);
    // print("year called: " + _currentYear.toString());
    //  print("Month called: " + currentMonth.toString());
    // print("Day called: "+ DateTime.monday.toString());
    // print("thing for now:" + (DateTime(_currentYear, nextMonth, 0).weekday).toString());
    // print("weekdays: " + (7 - DateTime(_currentYear, nextMonth, 0).weekday).toString());
    // print("la zigezonzinzon: " + DateTime(_currentYear, nextMonth, 0).weekday.toString());
    // print((7 - DateTime(_currentYear, nextMonth, 0).weekday - 1 ));

    // building a flex equivalent that allows calendar days to appear and wrap around one another
    return Container(
      color: colors["backgroundColor"],
      child: Column(
        children: [
          // ============================================================== GESTION DU MOIS
          Container(
            margin: const EdgeInsets.only(bottom: 15, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                    // Lorsqu'on clique, provoquer un changement de mois
                    onTap: () {
                      setState(() {
                        _monthChange = currentMonth - 1;
                        _dayClicked = -1;
                      });
                    },

                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 25.0,
                    ),
                ),
                Text(
                    "${arrayMonths[currentMonth-1]} $_currentYear",
                    style: const TextStyle(fontSize: 25)
                ),
                GestureDetector(
                  // Lorsqu'on clique, provoquer un changement de mois
                  onTap: () {
                    setState(() {
                      _monthChange = currentMonth + 1;
                      _dayClicked = -1;
                    });
                  },
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 25.0,
                  ),
                ),
              ],
            ),
          ),
          // ============================================================== JOURS DE LA SEMAINE
          Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var dayName in arrayDays)
                    Container(child: Text(dayName, textAlign: TextAlign.center), width: MediaQuery.of(context).size.width / 7)
                ],
              )
          ),
          // ============================================================== CONTENEUR DES JOURS
          GestureDetector(
            // ======================================== DEBUGGING
            // TODO Enlver le debugging
            onTap: () {
              setState(() {
                print('day clicked: ${_dayClicked}');
              });
            },
              child: SizedBox(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  // child: day(),
                  children: [
                    /**
                     * JOURS DU MOIS
                     *
                     * DE LA MANIERE SUIVANTE
                     *      JOURS DU MOIS D'AVANT
                     *      JOURS DU MOIS PRESENT
                     *      JOURS DU MOIS SUIVANT
                     */
                    if(weekdays != 7)
                      for (var i = 0; i < weekdays; i++)...[
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                _monthChange = currentMonth - 1;
                                _dayClicked = -1;
                              });
                            },
                            child: day(
                                DateTime(_currentYear, previousMonth, 0).day + i - weekdays, currentMonth, _currentYear, false, -1
                            )
                        ),
                      ],

                    for (var i = 0; i < getAmountOfDays(); i++)...[
                      GestureDetector(
                          onTap: () {
                            setState(()=>{
                              _dayClicked = i
                            });
                          },
                          child: day(i, currentMonth, _currentYear, true, _dayClicked),
                      ),
                    ],

                    if(DateTime(nextYear, nextMonth, 0).weekday != 6)
                      for (var i = 0; i < ( DateTime(nextYear, nextMonth, 0).weekday == 7 ? 6 : (7 - DateTime(nextYear, nextMonth, 0).weekday - 1 )); i++)...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _monthChange = currentMonth + 1;
                              _dayClicked = -1;
                            });
                          },
                          child: day(i, currentMonth, _currentYear, false, -1),
                        ),
                      ]
                  ],
                ),
              ),
          ),
          /**
           * BUTTON TO ADD AN EVENT
           */
          GestureDetector(
            onTap: () {
              setState(() {
                //_listEvents = false;
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      /**
                       * Class that adds event
                       */
                      return AddEvent({
                        "day": (_dayClicked < 0 ? now.day : _dayClicked + 1),
                        "month": currentMonth,
                        "year": _currentYear,
                      });
                    }
                );
              });
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
          ),
          if (_dayClicked != -1)
            EvenementsJour({"year": _currentYear, "month": currentMonth,"day": _dayClicked+1,})
        ],
      ),
    );

  }
}

