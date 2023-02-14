import '../res/settings.dart';

class Schedule {
  static List get ListSchedule {
    listeHoraires.sort((a, b) => (a['name'].toLowerCase()).compareTo(b['name'].toLowerCase()));
    return listeHoraires;
  }
}