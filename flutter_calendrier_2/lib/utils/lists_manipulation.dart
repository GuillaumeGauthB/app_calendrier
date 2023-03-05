import 'package:flutter_calendrier_2/res/checklists.dart';
import 'package:get/get.dart';

import '../res/events.dart';
import '../res/settings.dart';

/// Classe qui ordonne des listes precises
class ListsManipulation {
  /// ressort la liste des horaires ordonnees alphabetiquement
  static List get ListSchedule {
    // Ordonner les listes alphabetiquement, du plus petit au plus grand
    listeHoraires.sort((a, b) => (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase()));
    return listeHoraires;
  }

  /// ressort la liste des evenements d'une certaine date
  static List ListEventSchedule({
    required int day,
    required int month,
    required int year,
  }) {

    /// temps present
    DateTime now = DateTime.now();

    /// Premiere liste des evenements
    var data = tableaux_evenements;

    /// Liste qui va etre utiliser pour imprimer les evenements de la journee
    var dataWhere = [];

    /// Trier les evenements de la liste, ressortir juste ceux de la date choisie
    for (var o in data) {
      if(o['day'] == day && o['month'] == month && o['year'] == year){
        dataWhere.add(o);
      }
    }

    /// Trouver les horaires concernant la date choisie
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

    /// Si un resultat a ete trouver, trouver les evenements
    if(activeSchedules.isNotEmpty){
      var schedulesEvents = data.where(
              (element) =>  dataWhere.firstWhereOrNull((elementNow) => elementNow['id'] == element['id'] && elementNow['id']!= null) == null &&
              element['schedule'] != null &&
              activeSchedules.where((elementSchedule) => element['schedule'] == elementSchedule['id']).isNotEmpty

      );

      /// Prendre les evenements specifiques a la journee et a l'horaire
      if(schedulesEvents != null){
        var schedulesEventsToAdd = schedulesEvents.where(
                (element) {
              var currentSchedule = activeSchedules.toList().firstWhereOrNull((elementSchedule) => elementSchedule['id'] == element['schedule']);
              DateTime elTime = DateTime(element['year'], element['month'], element['day']);
              if(currentSchedule != null){
                /// Verifier si l'evenement se repete a chaque semaine, mois ou annee
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

        /// Ajouter ces evenements a la liste dataWhere
        for(var event in schedulesEventsToAdd){
          dataWhere.add(event);
        }
      }
    }
    /// Retourner la liste des evenements
    return dataWhere;
  }

  /// Retourne une liste des types d'evenements
  static Map<String, bool> GetEventTypes({required List list, bool condition = true}){
    /// Initialisation d'un Map contenant les types d'evenements concernes
    Map<String, bool> returnMap = {
      'event': false,
      'schedule': false
    };

    /// Si la liste des evenements n'est pas vide et que la condition est vrai,
    /// chercher pour les types d'items
    if(list.isNotEmpty && condition){
      if(list.firstWhereOrNull((element) => element['schedule'] != null) != null){
        returnMap['schedule'] = true;
      }

      if(list.firstWhereOrNull((element) => element['schedule'] == null) != null){
        returnMap['event'] = true;
      }
    }

    /// Retouner le Map avec les types d'evenements
    return returnMap;
  }

  /// Retourne la liste des checklists ordonnees premierement par lesquelles sont completees, puis alphabetiquement
  static List get ListChecklists {

    /// diviser les listes dependamment de leur statut
    List liste1 = listeChecklists.where((a) => !a['completed']).toList();

    List liste2 = listeChecklists.where((a) => a['completed']).toList();

    /// trier les listes par ordre alphabetique
    liste1.sort((a, b) {
      return (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase());
    });

    liste2.sort((a, b) {
      return (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase());
    });

    /// concatener les listes
    liste1.addAll(liste2);

    listeChecklists = liste1;

    /// retourner la liste trier
    return listeChecklists;
  }
}