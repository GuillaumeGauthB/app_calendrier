import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:datepicker_dropdown/datepicker_dropdown.dart';

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
  final Map<String?, dynamic> listControllers = {
    "title": TextEditingController(),
    "description": TextEditingController(),
  };
  late Map<String, dynamic> infoDate;

  _AddEventState(this.parentParameters);

  @override
  void dispose() {
    // TODO Potential error here, look at it later
    listControllers.map((key, value) => listControllers[key].dispose());
  }

  @override
  Widget build(BuildContext context) {
    infoDate = {
      "day": parentParameters["day"],
      "month": parentParameters["month"],
      "year": parentParameters["year"]
    };

    print('testtesttesttesttest');

    print(parentParameters);
    return Form(
      key: _formKey,
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
            endYear: 3000,
            onChangedDay: (value) =>  infoDate["day"] = value,
            onChangedMonth: (value) => {infoDate["month"] = value, print('month: '+infoDate["month"].toString())},
            onChangedYear: (value) => infoDate["year"] = value,
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
                    String documentID = '${infoDate["year"]}_${infoDate["month"]}_${infoDate["day"]}';

                    // Lien a la collection Firebase
                    CollectionReference ref = FirebaseFirestore.instance.collection('Calendrier').doc(documentID).collection('evenements');

                    QuerySnapshot lengthCollection;
                    FirebaseFirestore.instance.runTransaction((transaction) async => {
                      lengthCollection = await ref.limit(1).get(),
                      //print('length: '+lengthCollection.toString()),
                      if(lengthCollection.docs.isEmpty){
                        print('test'),
                        FirebaseFirestore.instance.collection('Calendrier').doc(documentID).set({})
                      },
                      await ref.add({
                        'Titre': listControllers["title"].text
                      })
                    });
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },

                child: Text('Submit'),
              )),
        ],
      ),
    );
  }
}

