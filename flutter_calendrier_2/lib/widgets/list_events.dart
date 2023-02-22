import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/utils/lists_manipulation.dart';
import '../res/events.dart';
import '../res/values.dart';
import '../utils/file_utils.dart';
import 'package:get/get.dart';

import 'add_event.dart';


class ListEvents extends StatefulWidget {
  //const DayEvents({Key? key}) : super(key: key);

  final Map<String, dynamic> evenementsParameters;

  ListEvents(this.evenementsParameters);
  @override
  State<ListEvents> createState() => _ListEventsState(evenementsParameters);
}

class _ListEventsState extends State<ListEvents> {
  final GlobalKey _columnEventKey = GlobalKey();

  late Map<String, dynamic> evenementsParameters; // parametres envoyees du parent
  late int day, month, year; // informations de la date lue

  _ListEventsState(this.evenementsParameters);

  late DateTime now;

  MaterialStatePropertyAll<RoundedRectangleBorder>? firstEventBorder;

  /// fonction qui imprime les donnees a envoyer
  Widget printData({List widgetToSend = const []}) {
    return SizedBox.expand(
        child: DraggableScrollableSheet(
            maxChildSize: (widgetToSend.length >= 5 ? 0.75 : 0.40),
            initialChildSize: 0.40,
            minChildSize: 0.40,
            builder: (context, scrollController) {
              return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    //border: Border.all(color: Colors.black),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        spreadRadius: 5,
                        blurRadius: 50
                      )
                    ]
                  ),
                  child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        key: _columnEventKey,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /**
                           * BUTTON TO ADD AN EVENT
                           */
                          ...widgetToSend,
                        ],
                      )
                  )
              );
            }
        )
    );
  }

  /// fonction qui trouve les informations de tous les evenements de la journees choisie
  Future<List> get getData async{
    String tempsEvenements = '';

    // Lire les evenements
    var data = tableaux_evenements;
    // Liste qui va etre utiliser pour imprimer les evenements de la journee
    var dataWhere = [];
    // Mettre les bons evenements dans la liste
    for (var o in data) {
      if(o['day'] == day && o['month'] == month && o['year'] == year){
        dataWhere.add(o);
      }
    }

    /**
     * TRAITEMENT DES HORAIRES
     */
    var activeSchedules = ListsManipulation.ListSchedule.where(
            (element) => element['permanent'] != null &&
              element['permanent'] == true ||
              (
                  (
                      DateTime(element['year_beginning'], element['month_beginning'], element['day_beginning']).isBefore(now) &&
                      DateTime(element['year_end'], element['month_end'], element['day_end']).isAfter(now)
                  ) ||
                  DateTime(element['year_beginning'], element['month_beginning'], element['day_beginning']) == now ||
                  DateTime(element['year_end'], element['month_end'], element['day_end']) == now

              )
    );

    if(activeSchedules.isNotEmpty){
      var schedulesEvents = data.where(
              (element) =>  dataWhere.firstWhereOrNull((elementNow) => elementNow['id'] == element['id'] && elementNow['id']!= null) == null &&
              element['schedule'] != null &&
              activeSchedules.where((elementSchedule) => element['schedule'] == elementSchedule['id']).isNotEmpty

      );

      if(schedulesEvents != null){
        var schedulesEventsToAdd = schedulesEvents.where(
                (element) {
              var currentSchedule = activeSchedules.toList().firstWhereOrNull((elementSchedule) => elementSchedule['id'] == element['schedule']);
              DateTime elTime = DateTime(element['year'], element['month'], element['day']);
              if(currentSchedule != null){
                if(currentSchedule['repetition'] == 'week'){
                  if(now.weekday == elTime.weekday){
                    return true;
                  }
                } else if (currentSchedule['repetition'] == 'month'){
                  if(now.day == elTime.day){
                    return true;
                  }
                } else if(currentSchedule['repetition'] == 'year'){
                  if(now.month == elTime.month && now.day == elTime.day){
                    return true;
                  }
                }
              }
              return false;
            }
        );

        for(var event in schedulesEventsToAdd){
          dataWhere.add(event);
        }
      }
    }

    /**
     * FIN DU TRAITEMENT DES HORAIRES
     */
    

    // envoyer de base cet element
    List arrayToSend = [Text("Aucun évènement", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center,)];

    // mais si la liste avec ce qu'il y a a imprimer n'est pas vide, remplacer le contenu de arrayToSend par le contenu de dataWhere
    if(dataWhere.isNotEmpty){
      dataWhere.sort((a, b) => (a['title'].toLowerCase()).compareTo(b['title'].toLowerCase()));
      List<Widget> dataToPrint = [];
      for (var o in dataWhere) {
        if(dataToPrint.isEmpty){
          firstEventBorder = MaterialStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), topLeft: Radius.circular(20.0)),
                // side: BorderSide(color: Colors.red),
              )
          );
        } else {
          firstEventBorder = null;
        }

        if(o['entire_day'].runtimeType == bool && o['entire_day']){
          tempsEvenements = 'Journée';
        } else {
          if(o['periode_de_temps'].runtimeType == int && o['periode_de_temps'] == 1){
            tempsEvenements = '${o['hourBeginning']}:${(int.parse(o['minuteBeginning']) < 10 ? '0${o['minuteBeginning']}' : o['minuteBeginning'])} - ${o['hour']}:${(int.parse(o['minute']) < 10 ? '0${o['minute']}' : o['minute'])}';
          } else {
            tempsEvenements = '${o['hour']}:${(int.parse(o['minute']) < 10 ? '0${o['minute']}' : o['minute'])}';
          }
        }

        //var schedule = null;
        var schedule = ListsManipulation.ListSchedule.firstWhereOrNull((element) => element['id'] == o['schedule']);

        //print(Schedule.ListSchedule.singleWhere((element) => element['id'] == o['schedule']));

        dataToPrint.add(
          
            TextButton(
              style: ButtonStyle(
                shape: firstEventBorder,
                overlayColor: MaterialStatePropertyAll<Color>(schedule.runtimeType != Null ? Color(schedule['color_frontend']) : Colors.black),
                backgroundColor: MaterialStatePropertyAll<Color>(schedule.runtimeType != Null ? Color(schedule['color']) : Colors.transparent),
                foregroundColor: MaterialStatePropertyAll<Color>(schedule.runtimeType != Null ? Color(schedule['color_frontend']) : Theme.of(context).textTheme.bodyLarge!.color!),
                textStyle: MaterialStatePropertyAll<TextStyle>(Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white)),
              ),
              onPressed: () {
                showModalBottomSheet(
                    enableDrag: true,
                    isScrollControlled: true,
                    context: context, builder: (context) {
                      return Container(height: MediaQuery.of(context).size.height * 0.70, child: AddEvent({'id': o['id']}));
                    }
                ).whenComplete(() => {setState(() {})});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                      child: Text(
                        o['title'],
                        style: const TextStyle(
                          overflow: TextOverflow.fade,
                        ),
                        /*style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          overflow: TextOverflow.fade,
                        ),*/
                        textWidthBasis: TextWidthBasis.longestLine,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                  Row(
                      children: [
                        // Texte de duree / heure de l'event

                        Text(
                          tempsEvenements,
                        ),
                        TextButton(
                            onPressed: () {
                              tableaux_evenements.removeWhere((e) => e['id'] == o['id']);
                              FileUtils.modifyFile({}, mode: 'supprimer', id: o['id']);
                              setState(() {});
                            },
                            child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: schedule.runtimeType != Null ? Color(schedule['color_frontend']) : Theme.of(context).textTheme.bodyLarge!.color!),
                                  borderRadius: BorderRadius.all(Radius.circular(100)),
                                ),
                                child: Icon(Icons.delete_forever, color: schedule.runtimeType != Null ? Color(schedule['color_frontend']) : Theme.of(context).textTheme.bodyLarge!.color)
                            )
                        )
                      ]
                  )
                ],
              ),
            )
        );
      }

      arrayToSend = dataToPrint;
    }

    // retourner les informations
    return arrayToSend;
  }

  @override
  Widget build(BuildContext context) {
    // Les variables d'informations de journées
    day = widget.evenementsParameters['day'];
    month = widget.evenementsParameters['month'];
    year = widget.evenementsParameters['year'];

    now = DateTime(year, month, day);

    // FutureBuilder:: Widget qui traite la fonction AJAX de lecture
    return FutureBuilder(
        future: getData,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          // SI y'a une erreur dans le processus, Imprimer ce message
          if (snapshot.hasError) {
            return Text("Une erreur c'est produite -- ${snapshot.error.toString()}");
          }

          // Si retourne rien, imprimer rien
          if (snapshot.hasData && snapshot.data!.runtimeType == Widget) {
            return printData(widgetToSend: [const Text("Aucun évènement", textAlign: TextAlign.center,)]);
          }

          // Si retourne du contenu, imprimer les evenements
          if (snapshot.connectionState == ConnectionState.done) {
            return printData(widgetToSend: snapshot.data!);
          }

          return printData(widgetToSend: [Text("Aucun évènement",  style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center,)]);
        },
    );
  }
}