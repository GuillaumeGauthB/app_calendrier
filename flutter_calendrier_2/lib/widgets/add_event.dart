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
  Map<String, dynamic> eventParameters = {};
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  bool _valueCheckbox = true;
  Map<String, String> _infosTemps = {};
  final Map<String?, dynamic> listControllers = {
    "title": TextEditingController(),
    "description": TextEditingController(),
    //"temps_type": ,
    //"temps":
  };
  late Map<String, dynamic> _infoDate;

  String gestionClasse = 'ajouter';

  /*late final LocalNotificationService service;
  @override
  void initState(){
    service = LocalNotificationService();
    service.initialize();
    // not working
    super.initState();
  }*/

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
    eventParameters = parentParameters;

    if(parentParameters['id'].runtimeType.toString() != 'Null'){
      gestionClasse = 'modifier';
      eventParameters = tableaux_evenements.singleWhere((e) => e['id'] == parentParameters['id']);
    }

    print('eventParameters: $eventParameters');

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
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        // TODO remove test prints
                        // print("month: "+infoDate["month"].toString());
                        // print(listControllers["description"].text);
                        // print(infoDate);

                        // TODO essayer de faire moins d'operations
                        // L'ID du document qui va etre utiliser
                        //String documentID = '${infoDate["year"]}_${infoDate["month"]}_${infoDate["day"]}';

                        // Lien a la collection Firebase
                        //CollectionReference ref = FirebaseFirestore.instance.collection('Calendrier').doc(documentID).collection('evenements');

                        List tableau_id = [];
                        if(tableaux_evenements.isNotEmpty){
                          tableaux_evenements.forEach((x) => {if(x['id'] != null) tableau_id.add(x['id'])});
                        }

                        int current_id = 0;

                        print(tableau_id);
                        if(tableau_id.length > 0){
                          current_id = tableau_id.reduce((value, element) => value > element ? value : element);
                          current_id++;
                        }

                        //QuerySnapshot lengthCollection;
                        // TODO trouver une meilleure maniere de faire ca
                        Object eventToAdd = {
                          'id': (gestionClasse == 'modifier' ? parentParameters['id'] : current_id),
                          'title': '${listControllers["title"]?.text}',
                          'description': '${listControllers["description"]?.text}',
                          'day': _infoDate["day"],
                          'month': _infoDate["month"],
                          'year': _infoDate["year"],
                          'entire_day': _valueCheckbox,
                        };

                        if(!_valueCheckbox){
                          eventToAdd = {
                            'id': (gestionClasse == 'modifier' ? parentParameters['id'] : current_id),
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
                        if(tableaux_evenements.isNotEmpty)
                          tableaux_evenements.removeWhere((e) => e['id'] == parentParameters['id']);
                        tableaux_evenements.add(eventToAdd);
                        //tableaux_evenements.add(eventToAdd);
                        /*() async {
                          await service.showNotification(id: 0, title: 'Notification Title', body: 'Some body');
                        };*/

                        FileUtils.modifyFile(eventToAdd, mode: gestionClasse, id: parentParameters['id']);


                        // TODO fix le firebase fucker et faire fonctionner avec la modification

                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                      };
                      testState = 1;
                      if(gestionClasse == 'ajouter'){
                        Navigator.pop(context);
                      } else{
                        Get.offAllNamed('/calendrier', arguments: { 'day': eventParameters['day'], 'month': eventParameters['month'], 'year': eventParameters['year']});
                        //Get.back();
                      }
                    },

                    child: Text('Ajouter'),
                  )),
            ],
          ),
        )
    );
  }
}

// Vieille maniere de traiter l'info
/*Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TODO Temps ne s'update plus quand on le change
                    const Text('Heure: '),
                    Container(
                      margin: const EdgeInsets.only(right: 35),
                      child: DropdownButton<String>(
                          items: [
                            for(int i = 0; i <= 24; i++)
                              DropdownMenuItem<String>(
                                value: i < 10 ? '0${i.toString()}' : i.toString(),
                                child: Text(i < 10 ? '0${i.toString()}' : i.toString()),
                              ),
                          ],
                          value: _infosTemps["hour"],
                          onChanged: (String? value) {
                            setState(() {
                              _infosTemps["hour"] = value!;
                            });
                          }
                      ),
                    ),
                    const Text('Minute: '),
                    DropdownButton<String>(
                        items: [
                          for(int i = 0; i <= 60; i++)
                            DropdownMenuItem<String>(
                              value: i < 10 ? '0${i.toString()}' : i.toString(),
                              child: Text(i < 10 ? '0${i.toString()}' : i.toString()),
                            ),
                        ],
                        value: _infosTemps["minute"],
                        onChanged: (String? value) {
                          setState(() {
                            _infosTemps["minute"] = value!;
                          });
                        }
                    ),
                  ],
                ),*/
/*TimePickerDialog(
                  initialTime: TimeOfDay.now(),
                  initialEntryMode: TimePickerEntryMode.input,
                ),*/

class TimeDate extends StatefulWidget {
  const TimeDate({Key? key}) : super(key: key);

  @override
  State<TimeDate> createState() => _TimeDateState();
}

class _TimeDateState extends State<TimeDate> {
  bool _valueCheckbox = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /*CheckboxListTile(
          title: const Text("Journée entière"), //    <-- label
          value: _valueCheckbox, onChanged: (bool? value) {  },
        ),*/


      ],
    );
  }
}


