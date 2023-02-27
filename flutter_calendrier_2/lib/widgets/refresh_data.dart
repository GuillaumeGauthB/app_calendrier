import 'dart:convert';
import '../res/checklists.dart';
import '../res/events.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../res/settings.dart';
import '../utils/file_utils.dart';

class RefreshData {
  static List<String> itemsColl = [
    'Calendrier',
    'Horaires',
    'Checklists'
  ];

  static void getData({String? collection}) {
    if(collection != null && collection.isNotEmpty) {
      getDataCol(collection: collection);
    } else {
      for(String item in itemsColl){
        getDataCol(collection: item);
      }
    }
  }

  static void getDataCol({required String collection}) async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collection).get();

    List<Object?> result_3 = [];
    var result = await querySnapshot.docs.map((doc) => result_3.add(doc.data()));

    // dunno why this gotta stick but apparently it does
    String result_s = result.toString();

    print(result_3.length);

    if(collection == 'Calendrier'){
      FileUtils.saveToFile(data: jsonEncode(result_3));
    } else {
      FileUtils.saveToFile(data: jsonEncode(result_3), fileName: '${collection.toLowerCase()}.json');
    }
    tableaux_evenements = jsonDecode(await FileUtils.readFromFile());
  }

  /*static void get getDataCal async{

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

  static void get getDataHor async{

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

  static void get getDataCheck async{

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Checklists').get();

    List<Object?> result_3 = [];
    var result = await querySnapshot.docs.map((doc) => result_3.add(doc.data()));

    // dunno why this gotta stick but apparently it does
    String result_s = result.toString();

    print(result_3.length);

    FileUtils.saveToFile(data: jsonEncode(result_3), fileName: 'checklists.json');
    listeChecklists = result_3;

    print(await FileUtils.readFromFile(fileName: 'checklists.json'));
  }*/
}

/**
class RefreshData extends StatelessWidget {
  const RefreshData({Key? key}) : super(key: key);

  static void get getData {
    getDataHor();
    getDataCal();
    getDataCheck();
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

  static void getDataCheck() async{

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Checklists').get();

    List<Object?> result_3 = [];
    var result = await querySnapshot.docs.map((doc) => result_3.add(doc.data()));

    // dunno why this gotta stick but apparently it does
    String result_s = result.toString();

    print(result_3.length);

    FileUtils.saveToFile(data: jsonEncode(result_3), fileName: 'checklists.json');
    listeChecklists = result_3;

    print(await FileUtils.readFromFile(fileName: 'checklists.json'));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
          getDataHor();
          getDataCheck();
          getDataCal();

        },
      child: const Align(
        alignment: Alignment.center,
        child: Icon(
            Icons.refresh,
        ),
      ),
    );
  }
}
*/
