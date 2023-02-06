import 'package:cloud_firestore/cloud_firestore.dart'; // firestore, pour les transactions avec la db
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // flutter
import 'package:datepicker_dropdown/datepicker_dropdown.dart'; // Pour les dropdowns de date
 import 'package:flutter_calendrier_2/res/events.dart';
// import '../services/local_notification_service.dart';
import '../utils/FileUtils.dart';
import 'package:get/get.dart';
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

  // parameters de l'evenement existant deja
  Map<String, dynamic> eventParameters = {};

  // equivalent de l'id du formulaire
  final _formKey = GlobalKey<FormState>();

  // etat du checkbox de journee entiere
  bool _valueCheckbox = true;

  // les infos a propos du temps de l'evenement
  Map<String, String> _infosTemps = {};

  // une liste contenant tous les controllers (input)
  final Map<String?, dynamic> listControllers = {
    "title": TextEditingController(),
    "description": TextEditingController(),
    //"temps_type": ,
    //"temps":
  };

  // Les informations de la date
  late Map<String, dynamic> _infoDate;

  // le mode de la classe, peut etre ajouter ou modifier
  String gestionClasse = 'ajouter';

  _AddEventState(this.parentParameters);
/*
  @override
  void dispose() {
    // TODO Potential error here, look at it later
    listControllers.forEach((key, value) {
      value.dispose();
    });
  }
*/

  @override
  Widget build(BuildContext context) {
    // copier les parametres du parent pour les parametres de l'evenement
    eventParameters = parentParameters;

    // si le param id existe, mettre en mode modification et prendre les informations de cet evenement
    if(parentParameters['id'].runtimeType.toString() != 'Null'){
      gestionClasse = 'modifier';
      eventParameters = tableaux_evenements.singleWhere((e) => e['id'] == parentParameters['id']);
    }

    // si la classe est toujours en mode ajouter, mettre les informations envoyees
    if(gestionClasse == 'ajouter'){
      _infoDate = {
        "day": eventParameters["day"],
        "month": eventParameters["month"],
        "year": eventParameters["year"],
      };

      _infosTemps = {
        "hour": TimeOfDay.now().hour.toString(),
        "minute": TimeOfDay.now().minute.toString(),
      };
    } else {
      // Sinon, mettre les informations de l'evenement
      _infoDate = {
        "day": eventParameters["day"],
        "month": eventParameters["month"],
        "year": eventParameters["year"],
      };
      _infosTemps = {
        "hour": eventParameters['hour'].runtimeType.toString() != 'Null' ? eventParameters['hour'] : TimeOfDay.now().hour.toString(),
        "minute": eventParameters['minute'].runtimeType.toString() != 'Null' ? eventParameters['minute'] : TimeOfDay.now().minute.toString(),
      };

      listControllers['title']?.text = eventParameters['title'];
      listControllers['description']?.text = eventParameters['description'];
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                        textAlign: TextAlign.center,
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
                onChangedDay: (value) =>  _infoDate["day"] = value,
                onChangedMonth: (value) => {_infoDate["month"] = value},
                onChangedYear: (value) => _infoDate["year"] = value,
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
                CupertinoTimerPicker(
                  onTimerDurationChanged: (Duration value) {
                    _infosTemps["hour"] = value.inHours.toString();
                    _infosTemps["minute"] = (value.inMinutes - (value.inHours * 60)).toString();
                  },
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(hours: int.parse(_infosTemps["hour"]!), minutes: int.parse(_infosTemps["minute"]!)),
                ),
              Container(
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Si le formulaire est valider...
                      if (_formKey.currentState!.validate()) {

                        // Si le tableau n'est pas vide, incrementer l'id le plus elever de 1, sinon, mettre 0
                        List tableau_id = [];
                        if(tableaux_evenements.isNotEmpty){
                          tableaux_evenements.forEach((x) => {if(x['id'] != null) tableau_id.add(x['id'])});
                        }

                        int currentId = 0;

                        if(tableau_id.length > 0){
                          currentId = tableau_id.reduce((value, element) => value > element ? value : element);
                          currentId++;
                        }

                        // Initialisation de l'objet a envoyer
                        // TODO trouver une meilleure maniere de faire ca
                        Object eventToAdd = {
                          'id': (gestionClasse == 'modifier' ? parentParameters['id'] : currentId),
                          'title': '${listControllers["title"]?.text}',
                          'description': '${listControllers["description"]?.text}',
                          'day': _infoDate["day"],
                          'month': _infoDate["month"],
                          'year': _infoDate["year"],
                          'entire_day': _valueCheckbox,
                        };

                        if(!_valueCheckbox){
                          eventToAdd = {
                            'id': (gestionClasse == 'modifier' ? parentParameters['id'] : currentId),
                            'title': listControllers["title"]?.text,
                            'description': listControllers["description"]?.text,
                            'day': _infoDate["day"],
                            'month': _infoDate["month"],
                            'year': _infoDate["year"],
                            'entire_day': _valueCheckbox,
                            'hour': _infosTemps['hour'],
                            'minute': _infosTemps['minute'],
                          };
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
                      //if(gestionClasse == 'ajouter'){
                        // fermer la boite modale
                        Navigator.pop(context);
                      /*} else{
                        Get.offAllNamed('/calendrier', arguments: { 'day': eventParameters['day'], 'month': eventParameters['month'], 'year': eventParameters['year']});
                        //Get.back();
                      }*/
                    },

                    child: Text( (gestionClasse == 'ajouter' ? 'Ajouter' : 'Modifier')),
                  )),
            ],
          ),
        )
    );
  }
}

