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

  late Map<String, dynamic> evenementsParameters;

  EvenementsJour(this.evenementsParameters);
  @override
  State<EvenementsJour> createState() => _EvenementsJourState(evenementsParameters);
}

class _EvenementsJourState extends State<EvenementsJour> {
  bool _listEvents = true;
  GlobalKey _columnEventKey = GlobalKey();

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

    List widgetToSend = [const Text("Aucun évènement")];

    if(dataWhere.isNotEmpty){
      List<Widget> dataToPrint = [];
      dataWhere.forEach((o) => {
        //print(o),
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

      widgetToSend = dataToPrint;



        /*SizedBox.expand(

      );*/

      /*Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dataToPrint,
          ),
        ),
      );*/
    }

    return SizedBox.expand(
        child: DraggableScrollableSheet(
            maxChildSize: 0.75,
            initialChildSize: 0.45,
            minChildSize: 0.45,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        //border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        key: _columnEventKey,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /**
                           * BUTTON TO ADD AN EVENT
                           */
                          GestureDetector(
                            onTap: () {
                              //setState(() {
                              showModalBottomSheet(
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    /**
                                     * Class that adds event
                                     */
                                    return Container(
                                        height: MediaQuery.of(context).size.height * 0.70,
                                        child:AddEvent({
                                          "day": day,
                                          "month": month,
                                          "year": year
                                        })
                                    );
                                  }
                              ).whenComplete(() => {setState(() {}), print('testtstsestestetestes')});
                            },

                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.all(Radius.circular(35)),
                              ),

                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('Ajouter un évènement'),
                                    Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 25.0,
                                    ),
                                  ]
                              ),
                            ),
                          ),
                          ...widgetToSend
                        ],
                      )
                  )
              );
            }
        )
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
            return Text("Aucun évènement");
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