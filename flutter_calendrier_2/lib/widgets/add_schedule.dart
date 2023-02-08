import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../res/settings.dart';
import '../utils/FileUtils.dart';

class AddSchedule extends StatelessWidget {
  //const AddSchedule({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> listControllers = {
      "name": TextEditingController(),
      "description": TextEditingController()
  };
  final DateTime now = DateTime.now();

  final Map<String, dynamic> infoDate = {},
                      currentScheduleParameters = {},
                      originalScheduleParameters = {};


  @override
  Widget build(BuildContext context) {
    currentScheduleParameters["year_beginning"] = originalScheduleParameters['year_beginning'] ?? now.year;
    currentScheduleParameters["month_beginning"] = originalScheduleParameters['month_beginning'] ?? now.month;
    currentScheduleParameters["day_beginning"] = originalScheduleParameters['day_beginning'] ?? now.day;
    currentScheduleParameters["year_end"] = originalScheduleParameters['year_end'] ?? now.year;
    currentScheduleParameters["month_end"] = originalScheduleParameters['month_end'] ?? now.month;
    currentScheduleParameters["day_end"] = originalScheduleParameters['day_end'] ?? now.day;
    currentScheduleParameters["color"] = originalScheduleParameters['color'] ?? Null;

    print(currentScheduleParameters);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Expanded(
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
                    controller: listControllers["name"],
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
                  const Center(
                    child: Text('DE:'),
                  ),
                  DropdownDatePicker(
                    selectedYear: currentScheduleParameters["year_beginning"],
                    selectedMonth: currentScheduleParameters['month_beginning'],
                    selectedDay: currentScheduleParameters["day_beginning"],
                    startYear: now.year - 10,
                    endYear: DateTime.now().year + 20,
                    onChangedDay: (value) =>  currentScheduleParameters["day_beginning"] = value,
                    onChangedMonth: (value) => currentScheduleParameters["month_beginning"] = value,
                    onChangedYear: (value) => currentScheduleParameters["year_beginning"] = value,
                  ),
                  const Center(
                    child: Text('A:'),
                  ),
                  DropdownDatePicker(
                    selectedYear: currentScheduleParameters["year_end"],
                    selectedMonth: currentScheduleParameters['month_end'],
                    selectedDay: currentScheduleParameters["day_end"],
                    startYear: DateTime.now().year - 10,
                    endYear: DateTime.now().year + 20,
                    onChangedDay: (value) =>  currentScheduleParameters["day_end"] = value,
                    onChangedMonth: (value) => currentScheduleParameters["month_end"] = value,
                    onChangedYear: (value) => currentScheduleParameters["year_end"] = value,
                  ),
                  ColorPicker(
                    pickerColor: Colors.black,
                    enableAlpha: false,
                    onColorChanged: (Color color){
                      // print(color.)
                      print(color.value);
                      currentScheduleParameters["color"] = color.value;
                    },
                  )
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.40,
                child: ElevatedButton(
                  onPressed: () {Navigator.pop(context);},
                  child: Text('Annuler'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.40,
                child: ElevatedButton(
                  onPressed: () {
                    // Si le formulaire est valider...
                    if (_formKey.currentState!.validate()) {
                      // Si le tableau n'est pas vide, incrementer l'id le plus elever de 1, sinon, mettre 0
                      List tableau_id = [];
                      if(listeHoraires.isNotEmpty){
                        listeHoraires.forEach((x) => {if(x['id'] != null) tableau_id.add(x['id'])});
                      }

                      int currentId = 0;

                      if(tableau_id.length > 0){
                        currentId = tableau_id.reduce((value, element) => value > element ? value : element);
                        currentId++;
                      }

                      Map<String, dynamic> eventToAdd = {
                        'id': originalScheduleParameters['id'] ?? currentId,
                        'name': '${listControllers["name"]?.text}',
                        'description': '${listControllers["description"]?.text}',
                        'day_beginning': currentScheduleParameters["day_beginning"],
                        'month_beginning': currentScheduleParameters["month_beginning"],
                        'year_beginning': currentScheduleParameters["year_beginning"],
                        'day_end': currentScheduleParameters["day_end"],
                        'month_end': currentScheduleParameters["month_end"],
                        'year_end': currentScheduleParameters["year_end"],
                        'color': currentScheduleParameters['color']
                      };

                      // Si nous sommes en modification, supprimer du tableau deja loader l'evenement avec notre item present
                      if(listeHoraires.isNotEmpty && originalScheduleParameters['id'].runtimeType != Null){
                        listeHoraires.removeWhere((e) => e['id'] == originalScheduleParameters['id']);
                      }

                      // Ajouter le nouvel evenement au tableau local
                      listeHoraires.add(eventToAdd);

                      // Appeler la methode de la classe static pour envoyer nos modifications dans le fichier local json et dans la base de donnee
                      FileUtils.modifyFile(eventToAdd, collection: 'Horaires', mode: (originalScheduleParameters['id'].runtimeType == Null ? 'ajouter' : 'modifier'), id: originalScheduleParameters['id'], fileName: 'horaires.json');

                      // Faire apparaitre un snackbar pour dire que le tout a fonctionner
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajout de l\'évènement')),
                      );
                      Navigator.pop(context);
                    }
                  },

                  child: Text( 'Ajouter' /*(gestionClasse == 'ajouter' ? 'Ajouter' : 'Modifier')*/),
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}
