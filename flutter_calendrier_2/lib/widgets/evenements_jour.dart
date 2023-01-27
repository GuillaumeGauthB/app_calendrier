import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../res/values.dart';
import '../utils/FileUtils.dart';


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

  _EvenementsJourState(this.evenementsParameters);
  /*
  Future<List> getData() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await calendrier.doc(documentID).collection("evenements").get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    return allData;
  }

  Widget eventSection(){
    if (_listEvents == true){
      return FutureBuilder<DocumentSnapshot>(
              //Fetching data from the documentId specified of the student
                future: calendrier.doc(documentID).get(),
                builder:
                    (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {


                  //Error Handling conditions
                  if (snapshot.hasError) {
                    return Text("Something went wrong -- ${snapshot.error.toString()}");
                  }

                  if (snapshot.hasData && !snapshot.data!.exists) {
                    return Text("Document does not exist");
                  }

                  //Data is output to the user
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                    //return Text("Full Name: ${data['valeurTest']}");
                    //getData().then((value) => dataDay = value);
                    return Container(
                        child:
                          //Text("Date:"+data['valeurTest']),
                        FutureBuilder(
                            future: getData()/*.then((value) => dataDay = value)*/,
                            builder: (BuildContext context, AsyncSnapshot<List> snapshot){
                              //Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                              if (snapshot.connectionState == ConnectionState.done) {
                                dataDay = snapshot.data!;
                                // TODO Allow scrolling here
                                return SingleChildScrollView(
                                    child: Column(
                                      children: dataDay.map((obj) =>
                                          Container(
                                            child: Text(
                                              obj['Titre'],
                                              style: TextStyle(color: colors['mainColor']),
                                            ),
                                            // height: 93.2,
                                            //height: double.minPositive,
                                          )).toList(),
                                  )
                                );
                              }
                              else{
                                return Text('Waiting for data...');
                              }
                            },
                          )
                    );
                    //return ListEvents();
                  }

                  return Text("loading");
                }
            );
    } else {
      return Container();
    }
  }
  */
  Future<Widget> tetsteste() async{
    // Lire les evenements
    var data = jsonDecode(await FileUtils.readFromFile);
    // Liste qui va etre utiliser pour imprimer les evenements de la journee
    var dataWhere = [];
    // Mettre les bons evenements dans la liste
    data.forEach((o) => {
      //print(o['annee'].toString()+'=$year'),
      if(o['jour'] == day && o['mois'] == month && o['annee'] == year)
        dataWhere.add(o),
    });
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
                o['Titre'],
                style: TextStyle(color: colors['mainColor']),
              ),
            ),
            Row(
              children: [
                Text(
                    (
                        (o['journee_entiere'].runtimeType.toString() == "bool" && o['journee_entiere']) ? 'Journée entière' : '${o['heure']}h${o['minute']}'
                    )
                )
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
    //print("height of screen: " + heightScreen.toString());
    day = widget.evenementsParameters['day'];
    month = widget.evenementsParameters['month'];
    year = widget.evenementsParameters['year'];
    //documentID = '${year}_${month}_${day}';
    //calendrier = FirebaseFirestore.instance.collection('Calendrier');


    //return eventSection();
    return FutureBuilder(
        future: tetsteste(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong -- ${snapshot.error.toString()}");
          }

          if (snapshot.hasData && snapshot.data!.runtimeType == 'Widget') {
            return Text("Document does not exist");
          }

          //Data is output to the user
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          }

          return const Text("loading");
        },
    );
  }
}
/**
 * AppBar(
    title: Text('test'),
    backgroundColor: colors['mainColor'],
    ),
 */