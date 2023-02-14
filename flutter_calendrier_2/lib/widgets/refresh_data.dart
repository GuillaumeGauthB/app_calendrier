import 'dart:convert';
import '../res/events.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../res/settings.dart';
import '../utils/file_utils.dart';


class RefreshData extends StatelessWidget {
  const RefreshData({Key? key}) : super(key: key);

  static void get getData {
    getDataHor();
    getDataCal();
  }

  static void getDataCal() async{

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Calendrier').get();

    List<Object?> result_3 = [];
    var result = await querySnapshot.docs.map((doc) => result_3.add(doc.data()));

    // dunno why this gotta stick but apparently it does
    String result_s = result.toString();

    print(result_3.length);

    FileUtils.saveToFile(data: jsonEncode(result_3));
    tableaux_evenements = jsonDecode(await FileUtils.readFromFile());
  }

  static void getDataHor() async{

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Horaires').get();

    List<Object?> result_3 = [];
    var result = await querySnapshot.docs.map((doc) => result_3.add(doc.data()));

    // dunno why this gotta stick but apparently it does
    String result_s = result.toString();

    print(result_3.length);

    FileUtils.saveToFile(data: jsonEncode(result_3), fileName: 'horaires.json');
    listeHoraires = jsonDecode(await FileUtils.readFromFile(fileName: 'horaires.json'));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
          getDataHor();
          getDataCal();
        },
      // TODO Customiser l'apparence du bouton
      child: const Align(
        alignment: Alignment.center,
        child: Icon(
            Icons.refresh,
        ),
      ),
    );
  }
}

