import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/res/events.dart';
import 'day.dart';
import 'list_events.dart';
import '../res/values.dart';
import 'add_event.dart';
import 'package:get/get.dart';
import '../utils/file_utils.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // Les infos de journees
  int _dayClicked = -1,
      _monthChange = -1,
      _currentYear = 0;

  // autres infos de mois
  late int currentMonth,
          previousMonth,
          nextMonth,
          previousYear,
          nextYear,
          weekdays;

  // nombre total de jours qui vont etre imprimer
  late int totalAmountDays;

  // Information pour aujourd'hui
  final DateTime now = DateTime.now();
  // Informations du mois present
  late DateTime currentMonthInfo;

  // Listes des jours et des mois a imprimer
  final List<String> arrayDays = [ 'Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa' ];
  final List<String> arrayMonths = [ 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre' ];

  /// avoir le nombre total de jours dans le mois
  int get getAmountOfDays {
    var amtDays = DateTime(_currentYear, currentMonth + 1, 0);
    return amtDays.day;
  }

  /// imprimer le calendrier en mode Landscape (pas encore fait)
  Widget get printCalendarLandscape {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.40,
              child: printCalendarBase,
            ),
            ListEvents({"year": _currentYear, "month": currentMonth,"day": (_dayClicked == -1 ? now.day : _dayClicked+1),}),
          ],
        )
      ],
    );
  }

  /// Imprimer le calendrier en mode portrait (original)
  Widget get printCalendarPortrait {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              printCalendarBase,
              ListEvents({"year": _currentYear, "month": currentMonth,"day": (_dayClicked == -1 ? now.day : _dayClicked+1),}),
            ],
          ),
        ),

        printAddEvent,
      ],
    );
  }

  /// Imprimer le core du calendrier
  Widget get printCalendarBase {
    return // ============================================================== GESTION DU MOIS
      Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  // Lorsqu'on clique, provoquer un changement de mois
                  onTap: () {
                    setState(() {
                      _monthChange = currentMonth - 1;
                      _dayClicked = -1;
                    });
                  },

                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).primaryColor,
                      size: 25.0,
                    ),
                  )
                ),
                Text(
                    "${arrayMonths[currentMonth-1]} $_currentYear",
                    style: Theme.of(context).textTheme.headlineMedium
                ),
                GestureDetector(
                  // Lorsqu'on clique, provoquer un changement de mois
                  onTap: () {
                    setState(() {
                      _monthChange = currentMonth + 1;
                      _dayClicked = -1;
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor,
                      size: 25.0,
                    ),
                  )
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
                    SizedBox(width: MediaQuery.of(context).size.width / 7, child: Text(dayName, textAlign: TextAlign.center),)
                ],
              )
          ),
          // ============================================================== CONTENEUR DES JOURS
          SizedBox(
            child: Wrap(
              alignment: WrapAlignment.start,
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
                            DateTime(_currentYear, previousMonth, 0).day + i - weekdays, currentMonth, _currentYear, false, -1,
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
      );
  }

  /// Imprimer le bouton d'ajout d'evenements
  Widget get printAddEvent {
    return Container(
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
                    child: AddEvent({
                      "day": _dayClicked != -1 ? _dayClicked + 1 : now.day,
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
    );
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

    // TODO jusqu'ici

    weekdays = DateTime(_currentYear, currentMonth, 1).weekday;

    // building a flex equivalent that allows calendar days to appear and wrap around one another
    return Container(
      color: Theme.of(context).backgroundColor,
      //padding: const EdgeInsets.only(top: 25),
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          // charger le bon mode dependamment de l'orientation du telephone
          if(orientation == Orientation.portrait){
            return printCalendarPortrait;
          } else {
            return printCalendarLandscape;
          }
        },
      )
    );

  }
}

