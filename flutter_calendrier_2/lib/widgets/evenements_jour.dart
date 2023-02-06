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

import 'add_event.dart';


class EvenementsJour extends StatefulWidget {
  //const EvenementsJour({Key? key}) : super(key: key);

  final Map<String, dynamic> evenementsParameters;

  EvenementsJour(this.evenementsParameters);
  @override
  State<EvenementsJour> createState() => _EvenementsJourState(evenementsParameters);
}

class _EvenementsJourState extends State<EvenementsJour> {
  final GlobalKey _columnEventKey = GlobalKey();

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
      if(valueArray['choice'] != 'Supprimer'){
        Get.toNamed("/calendrier/${valueArray['choice'].toLowerCase()}", arguments: valueArray['id']);
      }
      else{
        tableaux_evenements.removeWhere((e) => e['id'] == valueArray['id']);
        FileUtils.modifyFile({}, mode: 'supprimer', id: valueArray['id']);
        setState(() {});
      }
    }
  }

  Widget printData({List widgetToSend = const []}) {
    return SizedBox.expand(
        child: DraggableScrollableSheet(
            maxChildSize: (widgetToSend.length > 5 ? 0.75 : 0.40),
            initialChildSize: 0.40,
            minChildSize: 0.40,
            builder: (context, scrollController) {
              return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    //border: Border.all(color: Colors.black),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        key: _columnEventKey,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /**
                           * BUTTON TO ADD AN EVENT
                           */
                          ...widgetToSend,
                        ],
                      )
                  )
              );
            }
        )
    );
  }

  Future<List> get getData async{
    // Lire les evenements
    var data = tableaux_evenements;
    // Liste qui va etre utiliser pour imprimer les evenements de la journee
    var dataWhere = [];
    // Mettre les bons evenements dans la liste
    for (var o in data) {
      if(o['day'] == day && o['month'] == month && o['year'] == year){
        dataWhere.add(o);
      }
    }

    List arrayToSend = [Text("Aucun évènement", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center,)];

    if(dataWhere.isNotEmpty){
      List<Widget> dataToPrint = [];
      dataWhere.forEach((o) => {
        //print(o),
        dataToPrint.add(
          TextButton(
            style: const ButtonStyle(
              overlayColor: MaterialStatePropertyAll<Color>(Colors.black),
            ),
            onPressed: () {
              showModalBottomSheet(
                enableDrag: true,
                isScrollControlled: true,
                context: context, builder: (context) {
                  return Container(height: MediaQuery.of(context).size.height * 0.70, child: AddEvent({'id': o['id']}));
                }
              );
              print('test');
            },
            child: Row(
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
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Row(
                    children: [
                      // Texte de duree / heure de l'event

                      Text(
                          (
                              (o['entire_day'].runtimeType.toString() == 'bool' && o['entire_day']) ? 'Journée entière' : '${o['hour']}h${o['minute']}'
                          ), style: Theme.of(context).textTheme.bodyLarge
                      ),
                      TextButton(
                          onPressed: () {
                            tableaux_evenements.removeWhere((e) => e['id'] == o['id']);
                            FileUtils.modifyFile({}, mode: 'supprimer', id: o['id']);
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.white),
                              borderRadius: BorderRadius.all(Radius.circular(100)),
                            ),
                            child: Icon(Icons.delete_forever, color: Colors.white,)
                          ) 
                      )
                      // Menu Pop up
                      /*PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          onSelected: handleClick,
                          itemBuilder: (BuildContext context) {
                            return paramEvent.map((String choice) {
                              return PopupMenuItem<String>(
                                value: jsonEncode({'choice': choice, 'id': o['id']}),
                                child: Text(choice),
                              );
                            }).toList();
                          }),*/
                    ]
                )
              ],
            ),
          )
        ),
      });

      arrayToSend = dataToPrint;
    }

    return arrayToSend;
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
        future: getData,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          // SI y'a une erreur dans le processus, Imprimer ce message
          if (snapshot.hasError) {
            return Text("Une erreur c'est produite -- ${snapshot.error.toString()}");
          }

          // Si retourne rien, imprimer rien
          if (snapshot.hasData && snapshot.data!.runtimeType == 'Widget') {
            return printData(widgetToSend: [const Text("Aucun évènement", textAlign: TextAlign.center,)]);
          }

          // Si retourne du contenu, imprimer les evenements
          if (snapshot.connectionState == ConnectionState.done) {
            return printData(widgetToSend: snapshot.data!);
          }

          return printData(widgetToSend: [Text("Aucun évènement",  style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center,)]);
        },
    );
  }
}