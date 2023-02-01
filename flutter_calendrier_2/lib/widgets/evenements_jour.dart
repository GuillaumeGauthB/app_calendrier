import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../res/events.dart';
import '../res/values.dart';
import '../utils/FileUtils.dart';
import 'package:get/get.dart';


class EvenementsJour extends StatefulWidget {
  //const EvenementsJour({Key? key}) : super(key: key);

  late Map<String, dynamic> evenementsParameters;

  EvenementsJour(this.evenementsParameters);
  @override
  State<EvenementsJour> createState() => _EvenementsJourState(evenementsParameters);
}

class _EvenementsJourState extends State<EvenementsJour> {
  bool _listEvents = true;

  String documentID = '2022_12_31';
  late Map<String, dynamic> evenementsParameters;
  late int day, month, year;
  late CollectionReference calendrier;
  late List dataDay;
  late double heightScreen;

  final Set<String> paramEvent = {
    'Modifier', 'Supprimer'
  };

  _EvenementsJourState(this.evenementsParameters);

  void handleClick(String value){
    final valueArray = jsonDecode(value);
    if(paramEvent.contains(valueArray['choice'])){
      if(valueArray['choice'] != 'Supprimer')
        Get.toNamed("/calendrier/${valueArray['choice'].toLowerCase()}", arguments: valueArray['id']);
      else{
        tableaux_evenements.removeWhere((e) => e['id'] == valueArray['id']);
        FileUtils.modifyFile({}, mode: 'supprimer', id: valueArray['id']);
        setState(() {});
      }
    }
  }
  Future<Widget> tetsteste() async{
    // Lire les evenements
    var data = tableaux_evenements;
    // Liste qui va etre utiliser pour imprimer les evenements de la journee
    var dataWhere = [];
    // Mettre les bons evenements dans la liste
    data.forEach((o) => {
      //print(o['annee'].toString()+'=$year'),
      if(o['day'] == day && o['month'] == month && o['year'] == year)
        dataWhere.add(o),
    });
    print('data: $dataWhere');

    /*
      List tableau_id = [];
      tableaux_evenements.forEach((x) => {if(x['id'] != null) tableau_id.add(x['id'])});
      int current_id = 0;

      print(tableau_id);
      if(tableau_id.length > 0){
        current_id = tableau_id.reduce((value, element) => value > element ? value : element);
        current_id++;
      }

      print(current_id);
     */
    List<Widget> dataToPrint = [];
    dataWhere.forEach((o) => {
      print(o),
      dataToPrint.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
              //width: MediaQuery.of(context).size.width,
              /*decoration: const BoxDecoration(
                border: BorderDirectional(bottom: BorderSide(color: Colors.black, width: 0.7)),
                color: Colors.grey
              ),*/

              child: Text(
                o['title'],
                style: TextStyle(color: colors['mainColor']),
              ),
            ),
            Row(
              children: [
                // Texte de duree / heure de l'event
                Text(
                    (
                      (o['entire_day'].runtimeType.toString() == 'bool' && o['entire_day']) ? 'Journée entière' : '${o['hour']}h${o['minute']}'
                    )
                ),
                // Menu Pop up
                PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    return paramEvent.map((String choice) {
                      return PopupMenuItem<String>(
                        value: jsonEncode({'choice': '${choice}', 'id': o['id']}),
                        child: Text(choice),
                      );
                    }).toList();
                  }),
              ]
            )
          ],
        ),
      ),
    });


    return Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dataToPrint,
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    heightScreen = MediaQuery.of(context).size.height;


    // Les variables d'informations de journées
    day = widget.evenementsParameters['day'];
    month = widget.evenementsParameters['month'];
    year = widget.evenementsParameters['year'];


    //print('type de truc::: ${{'Logout', 'Settings'}.runtimeType}');

    // FutureBuilder:: Widget qui traite la fonction AJAX de lecture
    return FutureBuilder(
        future: tetsteste(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          // SI y'a une erreur dans le processus, Imprimer ce message
          if (snapshot.hasError) {
            return Text("Une erreur c'est produite -- ${snapshot.error.toString()}");
          }

          // Si retourne rien, imprimer rien
          if (snapshot.hasData && snapshot.data!.runtimeType == 'Widget') {
            return Text("");
          }

          // Si retourne du contenu, imprimer les evenements
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          }

          return const Text("En chargement...");
        },
    );
  }
}