import 'package:cloud_firestore/cloud_firestore.dart'; // firestore, pour les transactions avec la db
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // flutter
import 'package:datepicker_dropdown/datepicker_dropdown.dart'; // Pour les dropdowns de date
 import 'package:flutter_calendrier_2/res/events.dart';
import 'package:flutter_calendrier_2/res/settings.dart';
import 'package:flutter_calendrier_2/widgets/checkbox_item.dart';
// import '../services/local_notification_service.dart';
import '../res/checklists.dart';
import '../utils/file_utils.dart';
import 'package:get/get.dart';

import '../utils/lists_manipulation.dart';
/// Classe qui ajoute un evenement
class AddEvent extends StatefulWidget {
  //const AddEvent({Key? key}) : super(key: key);
  late Map<String, dynamic> parentParameters; // Liste des parametres recues

  AddEvent(this.parentParameters);

  @override
  State<AddEvent> createState() => _AddEventState(parentParameters);
}

class _AddEventState extends State<AddEvent> {
  late Map<String, dynamic> parentParameters; // Liste des parametres recues
  int firstState = 0;

  // parameters de l'evenement existant deja
  Map<String, dynamic> eventParameters = {};

  // equivalent de l'id du formulaire
  final _formKey = GlobalKey<FormState>();

  // etat du checkbox de journee entiere
  bool _valueCheckbox = true;
  int _valuePeriodeTemps = 0;

  // les infos a propos du temps de l'evenement
  Map<String, String> _infosTemps = {};
  Map<String, String> _infosTempsDebut = {};

  // une liste contenant tous les controllers (input)
  Map<String?, dynamic> listControllers = {
    "title": TextEditingController(),
    "description": TextEditingController(),
    //"temps_type": ,
    //"temps":
  };

  Map<String, dynamic> listContent = {};

  // Les informations de la date
  late Map<String, dynamic> _infoDate;

  // le mode de la classe, peut etre ajouter ou modifier
  String gestionClasse = 'ajouter';

  _AddEventState(this.parentParameters);

  List<Widget> get optionsTempsJournee {
    List<Widget> optionsTempsJournee = [];

    optionsTempsJournee.add(
      RadioListTile(
        title: const Text('Moment'),
        value: 0,
        groupValue: _valuePeriodeTemps,
        onChanged: (int? value) {
          setState(() {
            _valuePeriodeTemps = value!;
          });
        },
      ),
    );

    optionsTempsJournee.add(
      RadioListTile(
        title: const Text('Période'),
        value: 1,
        groupValue: _valuePeriodeTemps,
        onChanged: (int? value) {
          setState(() {
            _valuePeriodeTemps = value!;
          });
        },
      ),
    );

    if(_valuePeriodeTemps == 1) {
      optionsTempsJournee.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('De:'),
              SizedBox(
                //width: MediaQuery.of(context).size.width * 0.80,
                  height: 120,
                  child: CupertinoTimerPicker(
                    alignment: Alignment.centerRight,
                    onTimerDurationChanged: (Duration value) {
                      _infosTempsDebut["hour"] = value.inHours.toString();
                      _infosTempsDebut["minute"] =
                          (value.inMinutes - (value.inHours * 60)).toString();
                    },
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: Duration(
                        hours: int.parse(_infosTempsDebut["hour"]!),
                        minutes: int.parse(_infosTempsDebut["minute"]!)),
                  )
              )
            ],
          )
      );
    }
    optionsTempsJournee.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('À:'),
            SizedBox(
              //width: MediaQuery.of(context).size.width * 0.80,
                height: 120,
                child: CupertinoTimerPicker(
                  alignment: Alignment.centerRight,
                  onTimerDurationChanged: (Duration value) {
                    _infosTemps["hour"] = value.inHours.toString();
                    _infosTemps["minute"] = (value.inMinutes - (value.inHours * 60)).toString();
                  },
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(hours: int.parse(_infosTemps["hour"]!), minutes: int.parse(_infosTemps["minute"]!)),
                )
            )
          ],
        )
    );
    return optionsTempsJournee;
  }

  /// si la classe est toujours en mode ajouter, mettre les informations envoyees
  @override void initState() {
    // copier les parametres du parent pour les parametres de l'evenement
    eventParameters = parentParameters;

    // si le param id existe, mettre en mode modification et prendre les informations de cet evenement
    if(parentParameters['id'].runtimeType.toString() != 'Null'){
      gestionClasse = 'modifier';
      eventParameters = tableaux_evenements.singleWhere((e) => e['id'] == parentParameters['id']);
    }

    _infoDate = {
      "day": eventParameters["day"],
      "month": eventParameters["month"],
      "year": eventParameters["year"],
    };

    _infosTemps = {
      "hour": eventParameters['hour'] ?? TimeOfDay.now().hour.toString(),
      "minute": eventParameters['minute'] ?? TimeOfDay.now().minute.toString(),
    };

    _valueCheckbox = eventParameters['entire_day'] ?? true;

    _valuePeriodeTemps = eventParameters['periode_de_temps'] ?? 0;

    _infosTempsDebut = {
      "hour": eventParameters['hourBeginning'] ?? TimeOfDay.now().hour.toString(),
      "minute": eventParameters['minuteBeginning'] ?? TimeOfDay.now().minute.toString(),
    };

    listControllers['title']?.text = eventParameters['title'] ?? '';
    listControllers['description']?.text = eventParameters['description'] ?? '';

    eventParameters["associated_list"] = eventParameters["associated_list"];
  }

  /// le processing des donnees
  void processData() {
    // Si le formulaire est valider...
    if (_formKey.currentState!.validate()) {

      // Si le tableau n'est pas vide, incrementer l'id le plus elever de 1, sinon, mettre 0
      int currentId = FileUtils.getNewID(itemList: tableaux_evenements);

      Map<String, dynamic> eventToAdd = {
        'id': (gestionClasse == 'modifier' ? parentParameters['id'] : currentId),
        'title': '${listControllers["title"]?.text}',
        'description': '${listControllers["description"]?.text}',
        'day': _infoDate["day"],
        'month': _infoDate["month"],
        'year': _infoDate["year"],
        'entire_day': _valueCheckbox,
        'schedule': eventParameters['schedule'],
        'associated_list': eventParameters["associated_list"]
      };

      if(!_valueCheckbox){
        // eventToAdd['entire_day'] = _valueCheckbox;
        eventToAdd['hour'] = _infosTemps['hour'];
        eventToAdd['minute'] = _infosTemps['minute'];
        eventToAdd['periode_de_temps'] = _valuePeriodeTemps;

        if(_valuePeriodeTemps == 1){
          eventToAdd['hourBeginning'] = _infosTempsDebut['hour'];
          eventToAdd['minuteBeginning'] = _infosTempsDebut['minute'];
        }
      }

      // Si nous sommes en modification, supprimer du tableau deja loader l'evenement avec notre item present
      if(tableaux_evenements.isNotEmpty && gestionClasse != 'ajouter'){
        tableaux_evenements.removeWhere((e) => e['id'] == parentParameters['id']);
      }

      // Ajouter le nouvel evenement au tableau local
      tableaux_evenements.add(eventToAdd);

      // Appeler la methode de la classe static pour envoyer nos modifications dans le fichier local json et dans la base de donnee
      FileUtils.modifyFile(eventToAdd, mode: gestionClasse, id: parentParameters['id']);
      // Faire apparaitre un snackbar pour dire que le tout a fonctionner
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajout de l\'évènement')),
      );
    };
    Navigator.pop(context);
  }

  /// les horaires disponibles a selectionner
  List<DropdownMenuItem> get printSchedules {
    List schedules = ListsManipulation.ListSchedule;
    List<DropdownMenuItem> widgetsToSend = [];
    for(Map<String, dynamic> schedule in schedules){
      widgetsToSend.add(
        DropdownMenuItem(
          value: schedule['id'],
          child: Text(schedule['name'] ?? 'Horaire sans nom #${schedule['id']}'),
        ),
      );
    }
    return widgetsToSend;
  }

  /// les horaires disponibles a selectionner
  List<DropdownMenuItem> get printLists {
    List schedules = listeChecklists;
    List<DropdownMenuItem> widgetsToSend = [];
    for(Map<String, dynamic> schedule in schedules){
      widgetsToSend.add(
        DropdownMenuItem(
          value: schedule['id'],
          child: Text(schedule['name'] ?? 'Horaire sans nom #${schedule['id']}'),
        ),
      );
    }
    return widgetsToSend;
  }

  /// Methode les form inputs du formulaire
  List get formInputs {
    if(eventParameters['associated_list'] != null)
      listContent = listeChecklists.singleWhere((element) => element['id'] == eventParameters["associated_list"]);
    return [
      /**
       * Titre du formulaire
       */
      Container(
          margin: const EdgeInsets.only(bottom: 20.0, top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text(
                'Ajouter un évènement',
              ),
            ],
          )
      ),
      /**
       * Contenu du formulaire
       */
      // ============================================= NOM DE L'EVENEMENT
      TextFormField(
        decoration: const InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Nom',
          labelText: 'Nom de l\'évènement',
        ),
        controller: listControllers["title"],
        // style: Theme.of(context).,
        // style: Theme.of(context).textTheme.labelMedium,

        validator: (value) {
          // Empecher de sauvegarder un evenement sans titre
          if(value == null || value.isEmpty){
            return 'Veuillez saisir un titre';
          }
          return null;
        },
      ),
      // ============================================= DESCRIPTION
      TextFormField(
        decoration: const InputDecoration(
            icon: Icon(Icons.abc),
            labelText: 'Description'
        ),
        controller: listControllers["description"],
      ),
      /**
       * Choix de la date de l'evenement
       */
      DropdownDatePicker(
        selectedYear: eventParameters["year"],
        selectedMonth: eventParameters['month'],
        selectedDay: eventParameters["day"],
        startYear: DateTime.now().year - 10,
        endYear: DateTime.now().year + 20,
        onChangedDay: (value) =>  _infoDate["day"] = int.parse(value!),
        onChangedMonth: (value) => _infoDate["month"] = int.parse(value!),
        onChangedYear: (value) => _infoDate["year"] = int.parse(value!),
      ),

      DropdownButtonFormField(
        /*onChanged: (Object? objet) async {
          eventParameters["schedule"] = objet;
        },*/

        decoration: const InputDecoration(
            label: Text('Horaire')
        ),

        value: eventParameters["schedule"],

        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('Aucun horaire'),
          ),
          ...printSchedules,
        ],
        onChanged: (value) {
          eventParameters["schedule"] = value;
        },
      ),

      // ================================================= Journee entiere
      SizedBox(
        width: MediaQuery.of(context).size.width,
        child:CheckboxListTile(
          title: const Text("Journée entière", style: TextStyle(), textWidthBasis: TextWidthBasis.longestLine),
          value: _valueCheckbox,
          onChanged: (bool? value) {
            setState(() {
              _valueCheckbox = value!;
            });
          },
        ),
      ),

      // ================================================= Pas journee entiere
      if(!_valueCheckbox)
        ...optionsTempsJournee,

      if(eventParameters["associated_list"] != null)
        CheckboxItem(
          item: listContent,
          showAsWhole: true,
          heightToOpen: 35,
          checkChild: (String modified) {
            setState(() {
              listContent['${modified}_completed'] = !listContent['${modified}_completed'];
              FileUtils.modifyFile(listContent, fileName: 'checklists.json', mode: 'modifier', id: listContent['id'], collection: 'Checklists');
            });
          },
          // openedItemId: listContent['id'],
        ),
      
      DropdownButtonFormField(
        /*onChanged: (Object? objet) async {
          eventParameters["schedule"] = objet;
        },*/

        decoration: const InputDecoration(
            label: Text('Liste')
        ),

        value: eventParameters["associated_list"],

        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('Aucune liste'),
          ),
          ...printLists,
        ],
        onChanged: (value) {
          eventParameters["associated_list"] = value;
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...formInputs,
              /**
               * Bouton qui gere l'envoit des donnees
               */
              Container(
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),
                  child: ElevatedButton(
                    onPressed: processData,
                    child: Text( (gestionClasse == 'ajouter' ? 'Ajouter' : 'Modifier')),
                  )),
            ],
          ),
        )
    );
  }
}

