import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/res/events.dart';
import 'day.dart';
import 'evenements_jour.dart';
import '../res/values.dart';
import 'add_event.dart';
import 'package:get/get.dart';
import '../utils/FileUtils.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Map<String, dynamic> arguments = {};
  int _dayClicked = -1;
  int _monthChange = -1;
  int _currentYear = 0;

  int get dayClicked => _dayClicked;

  late int currentMonth,
          previousMonth,
          nextMonth,
          previousYear,
          nextYear,
          weekdays;

  late int totalAmountDays;

  final DateTime now = DateTime.now();
  late DateTime currentMonthInfo;


  // final List<String> arrayDays =  'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche' ];
   final List<String> arrayDays = [ 'Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa' ];
   final List<String> arrayMonths = [ 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre' ];

  int get getAmountOfDays {
    var amtDays = DateTime(_currentYear, currentMonth + 1, 0);
    return amtDays.day;
  }

  @override
  Widget build(BuildContext context) {
    totalAmountDays = 42;

    // TODO rendre la section suivante du code mieux
    // Traitement du changement des mois, can wait
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

    if(_currentYear == 0) {
      _currentYear = now.year;
    }

    if(Get.arguments.runtimeType.toString() != 'Null') {
      arguments= Get.arguments;

      if(arguments.isNotEmpty && arguments['day'] != -1){
        currentMonth = arguments['month'] as int;
        _currentYear = arguments['year'] as int;
        _dayClicked = arguments['day']! - 1;
        Get.arguments['day'] = -1;
      }
    }

    // TODO jusqu'ici
    //currentMonthInfo = DateTime(_currentYear, currentMonth, 31);
    weekdays = DateTime(_currentYear, currentMonth, 1).weekday;

    // building a flex equivalent that allows calendar days to appear and wrap around one another
    return Container(
      color: Theme.of(context).backgroundColor,
      //padding: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // ============================================================== GESTION DU MOIS
                Column(
                  children: [
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
                    SizedBox(
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
                            for (var i = 0; i < weekdays; i++, totalAmountDays--)...[
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

                          for (var i = 0; i < getAmountOfDays; i++, totalAmountDays--)...[
                            GestureDetector(
                              onTap: () {
                                setState(()=>{
                                  _dayClicked = i,
                                });
                              },
                              child: day(i, currentMonth, _currentYear, true, _dayClicked),
                            ),
                          ],

                          // Quand i est plus petit que le numero du premier jour du mois suivant
                          //for (var i = 0; i < ( DateTime(nextYear, nextMonth, 0).weekday == 7 ? 6 : (7 - DateTime(nextYear, nextMonth, 0).weekday - 1 )); i++)...[
                          for (var i = 0; i < totalAmountDays; i++)...[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _monthChange = currentMonth + 1;
                                  _dayClicked = -1;
                                });
                              },
                              child: day(i, currentMonth, (currentMonth == 12 ? _currentYear+1 : _currentYear), false, -1),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
                EvenementsJour({"year": _currentYear, "month": currentMonth,"day": (_dayClicked == -1 ? now.day : _dayClicked+1),}),

                /*Container(
            height: MediaQuery.of(context).size.height * 0.80,
            child: EvenementsJour({"year": _currentYear, "month": currentMonth,"day": (_dayClicked == -1 ? now.day : _dayClicked+1),}),
          ),*/
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: ElevatedButton(
              onPressed: () {
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
                            "day": _dayClicked + 1,
                            "month": currentMonth,
                            "year": _currentYear
                          })
                      );
                    }
                ).whenComplete(() => {setState(() {})});
              },



              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Ajouter un évènement'),
                    Icon(
                      Icons.add,
                      size: 25.0,
                    ),
                  ]
              ),
            ),
          )
          //),
          /*GestureDetector(
            onTap:

            child:
          ),*/
        ],
      )
      /*child: Column(
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
          SizedBox(
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
                  for (var i = 0; i < weekdays; i++, totalAmountDays--)...[
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

                for (var i = 0; i < getAmountOfDays(); i++, totalAmountDays--)...[
                  GestureDetector(
                      onTap: () {
                        setState(()=>{
                          _dayClicked = i,
                        });
                      },
                      child: day(i, currentMonth, _currentYear, true, _dayClicked),
                  ),
                ],

                // Quand i est plus petit que le numero du premier jour du mois suivant
                //for (var i = 0; i < ( DateTime(nextYear, nextMonth, 0).weekday == 7 ? 6 : (7 - DateTime(nextYear, nextMonth, 0).weekday - 1 )); i++)...[
                for (var i = 0; i < totalAmountDays; i++)...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _monthChange = currentMonth + 1;
                        _dayClicked = -1;
                      });
                    },
                    child: day(i, currentMonth, (currentMonth == 12 ? _currentYear+1 : _currentYear), false, -1),
                  ),
                ]
              ],
            ),
          ),
          /**
           * BUTTON TO ADD AN EVENT
           */
          GestureDetector(
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
                        "day": (_dayClicked < 0 ? now.day : _dayClicked + 1),
                        "month": currentMonth,
                        "year": _currentYear
                      })
                    );
                  }
              ).whenComplete(() => setState(() {}));
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
          EvenementsJour({"year": _currentYear, "month": currentMonth,"day": (_dayClicked == -1 ? now.day : _dayClicked+1),}),
          /*Container(
            height: MediaQuery.of(context).size.height * 0.80,
            child: EvenementsJour({"year": _currentYear, "month": currentMonth,"day": (_dayClicked == -1 ? now.day : _dayClicked+1),}),
          ),*/
        ],
      ),*/
    );

  }
}

