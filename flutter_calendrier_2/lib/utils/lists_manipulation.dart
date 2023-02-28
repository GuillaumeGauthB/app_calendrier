import 'package:flutter_calendrier_2/res/checklists.dart';

import '../res/settings.dart';

class ListsManipulation {
  /// ressort la liste des horaires ordonnees alphabetiquement
  static List get ListSchedule {
    listeHoraires.sort((a, b) => (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase()));
    return listeHoraires;
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