import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

import '../res/settings.dart';
import '../utils/file_utils.dart';

class AddSchedule extends StatefulWidget {
  //const AddSchedule({Key? key}) : super(key: key);
  final int? id;
  AddSchedule({int? this.id});

  @override
  State<AddSchedule> createState() => _AddScheduleState(id: id);
}

class _AddScheduleState extends State<AddSchedule> {
  final int? id;
  int firstRound = 0;
  bool isOpenPermanent = true;

  void onChanged(Color value) => currentScheduleParameters["color"] = value;
  void onChangedFrontEnd(Color value) => currentScheduleParameters["color_frontend"] = value;

  _AddScheduleState({int? this.id});

  late Map<String, dynamic> _infoDate;
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> listControllers = {
    "name": TextEditingController(),
    "description": TextEditingController()
  };
  final DateTime now = DateTime.now();

  Map<String, dynamic> currentScheduleParameters = {},
      originalScheduleParameters = {};

  @override
  void initState() {
    if(id.runtimeType != Null){
      originalScheduleParameters = listeHoraires.singleWhere((item) => item['id'] == id);
    }

    listControllers['name']?.text = originalScheduleParameters['name'] ?? '';
    listControllers['description']?.text = originalScheduleParameters['description'] ?? '';

    _infoDate = {
      "year_beginning": originalScheduleParameters['year_beginning'] ?? now.year,
      "month_beginning": originalScheduleParameters['month_beginning'] ?? now.month,
      "day_beginning": originalScheduleParameters['day_beginning'] ?? now.day,
      "year_end": originalScheduleParameters['year_end'] ?? now.year,
      "month_end": originalScheduleParameters['month_end'] ?? now.month,
      "day_end": originalScheduleParameters['day_end'] ?? now.day,
    };

    isOpenPermanent = originalScheduleParameters['permanent'] ?? true;

    currentScheduleParameters["color"] = originalScheduleParameters['color'] ?? Colors.black.value;
    currentScheduleParameters["color_frontend"] = originalScheduleParameters['color_frontend'] ?? Colors.white.value;
    currentScheduleParameters["repetition"] = originalScheduleParameters['repetition'] ?? 'none';
  }

  @override
  Widget build(BuildContext context) {

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
                          'Ajouter un horaire',
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
                      labelText: 'Nom de l\'horaire',
                    ),
                    controller: listControllers["name"],
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: CheckboxListTile(
                      title: const Text("Permanent", style: TextStyle(), textWidthBasis: TextWidthBasis.longestLine),
                      value: isOpenPermanent,
                      onChanged: (bool? value) {
                        setState(() {
                          isOpenPermanent = value!;
                        });
                      },
                    ),
                  ),
                  if(!isOpenPermanent)
                    ...printSectionTemporaire,
                  DropdownButtonFormField(
                    onChanged: (Object? objet) async {
                      currentScheduleParameters["repetition"] = objet;
                    },

                    decoration: const InputDecoration(
                        label: Text('Répétition')
                    ),

                    value: currentScheduleParameters["repetition"],

                    items: const [
                      DropdownMenuItem(
                        value: 'none',
                        child: Text('Aucune répétition'),
                      ),
                      DropdownMenuItem(
                        value: 'week',
                        child: Text('Chaque semaine'),
                      ),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text('Chaque mois'),
                      ),
                      DropdownMenuItem(
                        value: 'year',
                        child: Text('Chaque année'),
                      )
                    ],
                  ),
                  const Center(
                    heightFactor: 2,
                    child: Text('Couleur background'),
                  ),
                  RGBPicker(
                    color: currentScheduleParameters["color"].runtimeType == int ? Color(currentScheduleParameters["color"]) : currentScheduleParameters['color'],
                    onChanged: (value) => setState(
                          () => onChanged(value),
                    ),
                  ),
                  /*const Center(
                    heightFactor: 2,
                    child: Text('Couleur texte'),
                  ),
                  RGBPicker(
                    color: currentScheduleParameters["color_frontend"].runtimeType == int ? Color(currentScheduleParameters["color_frontend"]) : currentScheduleParameters['color_frontend'],
                    onChanged: (value) => setState(
                          () => onChangedFrontEnd(value),
                    ),
                  )*/
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

                        if(currentScheduleParameters["color"].runtimeType == Color){
                          currentScheduleParameters["color"] = currentScheduleParameters['color'].value;
                        }

                        if(currentScheduleParameters["color_frontend"].runtimeType == Color){
                          currentScheduleParameters["color_frontend"] = currentScheduleParameters['color_frontend'].value;
                        }

                        Map<String, dynamic> eventToAdd = {
                          'id': originalScheduleParameters['id'] ?? currentId,
                          'name': '${listControllers["name"]?.text}',
                          'description': '${listControllers["description"]?.text}',
                          'day_beginning': _infoDate["day_beginning"],
                          'month_beginning': _infoDate["month_beginning"],
                          'year_beginning': _infoDate["year_beginning"],
                          'day_end': _infoDate["day_end"],
                          'month_end': _infoDate["month_end"],
                          'year_end': _infoDate["year_end"],
                          'permanent': isOpenPermanent,
                          'color': currentScheduleParameters['color'],
                          'color_frontend': Color(currentScheduleParameters['color']).computeLuminance() > 0.5 ? Colors.black.value : Colors.white.value ,
                          'repetition': currentScheduleParameters["repetition"]
                        };

                        // print(eventToAdd['month_end'].runtimeType);

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

                    child: Text( (originalScheduleParameters['id'].runtimeType == Null ? 'Ajouter' : 'Modifier')),
                  )
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Contenu pour un horaire temporaire
  List<Widget> get printSectionTemporaire {
    return [
      const Center(
        child: Text('DE:'),
      ),
      DropdownDatePicker(
        selectedYear: _infoDate["year_beginning"],
        selectedMonth: _infoDate['month_beginning'],
        selectedDay: _infoDate["day_beginning"],
        startYear: now.year - 10,
        endYear: DateTime.now().year + 20,
        onChangedDay: (value) =>  _infoDate["day_beginning"] = int.parse(value!),
        onChangedMonth: (value) => _infoDate["month_beginning"] = int.parse(value!),
        onChangedYear: (value) => _infoDate["year_beginning"] = int.parse(value!),
      ),
      const Center(
        child: Text('A:'),
      ),
      DropdownDatePicker(
        selectedYear: _infoDate["year_end"],
        selectedMonth: _infoDate['month_end'],
        selectedDay: _infoDate["day_end"],
        startYear: DateTime.now().year - 10,
        endYear: DateTime.now().year + 20,
        onChangedDay: (value) =>  _infoDate["day_end"] = int.parse(value!),
        onChangedMonth: (value) => _infoDate["month_end"] = int.parse(value!),
        onChangedYear: (value) => _infoDate["year_end"] = int.parse(value!),
      ),
    ];
  }
}