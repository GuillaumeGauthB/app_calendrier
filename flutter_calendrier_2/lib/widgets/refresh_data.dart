import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/FileUtils.dart';


class RefreshData extends StatelessWidget {
  const RefreshData({Key? key}) : super(key: key);

void getData() async{
    QuerySnapshot collection_content;

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Calendrier').get();

    //Map<dynamic, dynamic> result = {};
    var result_2;
    List<Object?> result_3 = [];
    var result = await querySnapshot.docs.map((doc) => result_3.add(doc.data()));

    String result_s = result.toString();

    FileUtils.saveToFile(jsonEncode(result_3));
    //print(testste);
    //FileUtils.saveToFile(testste.toString());
    String test = await FileUtils.readFromFile();
    print(test);
    print(result_3.runtimeType);
  }

  @override
  Widget build(BuildContext context) {
    var test;
    return GestureDetector(
      onTap: (){
          getData();
        },
      // TODO Customiser l'apparence du bouton
      child: Text('Refresh'),
    );
  }
}

