import 'package:cloud_firestore/cloud_firestore.dart'; // firestore, pour les transactions avec la db
import 'package:flutter/material.dart'; // flutter
import 'package:datepicker_dropdown/datepicker_dropdown.dart'; // Pour les dropdowns de date
 import 'package:flutter_calendrier_2/res/events.dart';
// import '../services/local_notification_service.dart';
import '../utils/FileUtils.dart';

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
    _infoDate = {
      "day": parentParameters["day"],
      "month": parentParameters["month"],
      "year": parentParameters["year"],
    };

    _infosTemps = {
      "heure": TimeOfDay.now().hour.toString(),
      "minute": TimeOfDay.now().minute.toString(),
    };

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
                  icon: const Icon(Icons.person),
                  hintText: 'Nom',
                  labelText: 'Nom de l\'évènement',
                ),
                controller: listControllers["title"],
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
                selectedYear: parentParameters["year"],
                selectedMonth: parentParameters['month'],
                selectedDay: parentParameters["day"],
                startYear: DateTime.now().year - 10,
                endYear: DateTime.now().year + 20,
                onChangedDay: (value) =>  _infoDate["day"] = value,
                onChangedMonth: (value) => {_infoDate["month"] = value, print('month: '+_infoDate["month"].toString())},
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
                Row(
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
                          value: _infosTemps["heure"],
                          onChanged: (String? value) {
                            setState(() {
                              _infosTemps["heure"] = value!;
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
                ),
                /*TimePickerDialog(
                  initialTime: TimeOfDay.now(),
                  initialEntryMode: TimePickerEntryMode.input,
                ),*/
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

                        //QuerySnapshot lengthCollection;
                        Object eventToAdd = {
                          'Titre': listControllers["title"].text,
                          'description': listControllers["description"].text,
                          'jour': _infoDate["day"],
                          'mois': _infoDate["month"],
                          'annee': _infoDate["year"],
                          'journee_entiere': _valueCheckbox,
                        };

                        if(!_valueCheckbox){
                          // TODO trouver une meilleure maniere de faire ca
                          eventToAdd = {
                            'Titre': listControllers["title"].text,
                            'description': listControllers["description"].text,
                            'jour': _infoDate["day"],
                            'mois': _infoDate["month"],
                            'annee': _infoDate["year"],
                            'journee_entiere': _valueCheckbox,
                            'heure': _infosTemps['heure'],
                            'minute': _infosTemps['minute'],
                          };
                        }

                        tableaux_evenements.add(eventToAdd);
                        /*() async {
                          await service.showNotification(id: 0, title: 'Notification Title', body: 'Some body');
                        };*/

                        final CollectionReference ref = FirebaseFirestore.instance.collection('Calendrier');
                        try{
                          FirebaseFirestore.instance.runTransaction((transaction) async => {
                            // lengthCollection = await ref.limit(1).get(),
                            // TODO adapter ce code a la nouvelle maniere de faire
                            // Si la collection est vide, creer un document
                            //if(lengthCollection.docs.isEmpty){
                            //  FirebaseFirestore.instance.collection('Calendrier').doc(documentID).set({})
                            //},

                            await FileUtils.modifyFile(eventToAdd),

                            print(transaction),

                            // TODO ajouter une maniere de checker si des evenements ont ete ajoutees offline, pis les faire update quand on revient en ligne
                            await ref.add(eventToAdd),
                            //await addToFile()
                          });
                        } on Exception catch(e){
                          print('error:  $e');
                        }

                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                      };
                      testState = 1;
                      Navigator.pop(context);
                    },

                    child: Text('Submit'),
                  )),
            ],
          ),
        )
    );
  }
}

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


