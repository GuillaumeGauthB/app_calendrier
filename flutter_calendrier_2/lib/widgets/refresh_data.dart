import 'dart:convert';
import '../res/events.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/FileUtils.dart';


class RefreshData extends StatelessWidget {
  const RefreshData({Key? key}) : super(key: key);

void getData() async{

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Calendrier').get();

    //Map<dynamic, dynamic> result = {};
    //var result_2;
    List<Object?> result_3 = [];
    var result = await querySnapshot.docs.map((doc) => result_3.add(doc.data()));

    // dunno why this gotta stick but apparently it does
    String result_s = result.toString();

    print(result_3.length);

    FileUtils.saveToFile(jsonEncode(result_3));
    tableaux_evenements = jsonDecode(await FileUtils.readFromFile);
    //print(testste);
    //FileUtils.saveToFile(testste.toString());
    //String test = await FileUtils.readFromFile;
    //print(test);
    //print(result_3.runtimeType);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
          getData();
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

