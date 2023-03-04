import 'package:flutter_calendrier_2/res/checklists.dart';
import 'package:get/get.dart';

import '../res/events.dart';
import '../res/settings.dart';

class ListsManipulation {
  /// ressort la liste des horaires ordonnees alphabetiquement
  static List get ListSchedule {
    listeHoraires.sort((a, b) => (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase()));
    return listeHoraires;
  }

  /// ressort la liste des evenements d'horaires
  static List ListEventSchedule({
    required int day,
    required int month,
    required int year,
  }) {
    /**
     * TRAITEMENT DES HORAIRES
     */
    DateTime now = DateTime.now();
    // List data = tableaux_evenements;
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

    return dataWhere;
  }

  /// fonction qui permet de savoir quels types d'evenements font parties de la journee
  static Map<String, bool> GetEventTypes({required List list, bool condition = true}){
    Map<String, bool> returnMap = {
      'event': false,
      'schedule': false
    };

    if(list.isNotEmpty && condition){
      if(list.firstWhereOrNull((element) => element['schedule'] != null) != null){
        returnMap['schedule'] = true;
      }

      if(list.firstWhereOrNull((element) => element['schedule'] == null) != null){
        returnMap['event'] = true;
      }
    }

    return returnMap;
  }

  /// ressort la liste des checklists ordonnees premierement par lesquelles sont completees, puis alphabetiquement
  static List get ListChecklists {

    List liste1 = listeChecklists.where((a) => !a['completed']).toList();

    List liste2 = listeChecklists.where((a) => a['completed']).toList();

    liste1.sort((a, b) {
      return (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase());
    });

    liste2.sort((a, b) {
      return (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase());
    });

    liste1.addAll(liste2);

    listeChecklists = liste1;

    return listeChecklists;
  }
}