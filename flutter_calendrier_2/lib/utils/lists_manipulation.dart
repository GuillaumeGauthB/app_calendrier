import 'package:flutter_calendrier_2/res/checklists.dart';

import '../res/settings.dart';

class ListsManipulation {
  static List get ListSchedule {
    listeHoraires.sort((a, b) => (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase()));
    return listeHoraires;
  }

  static List get ListChecklists {

    List liste1 = listChecklists.where((a) => !a['completed']).toList();

    List liste2 = listChecklists.where((a) => a['completed']).toList();

    liste1.sort((a, b) {
      return (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase());
    });

    liste2.sort((a, b) {
      return (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase());
    });

    liste1.addAll(liste2);

    listChecklists = liste1;

    return listChecklists;
  }
}