import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_calendrier_2/utils/SharedPreferencesUtils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/file_utils.dart';
import '../res/events.dart';
import '../res/settings.dart';
import './widgets/refresh_data.dart';
import 'widgets/MyApp.dart';

/*Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}*/
bool isDarkTheme = true;

List testJSON = [];
int loop = 0;
var file;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // dark theme
  // isDarkTheme = await SharedPreferencesValues().getTheme;
  // tableau des evenements
  //await FileUtils.saveToFile('{\'hihiha\': \'hihiha\'}');
  await FileUtils.listInit;

  RefreshData.getData();
  //print(tableaux_evenements.runtimeType);
  //testJSON.runtimeType = tableaux_evenements.runtimeType;
  //print(tableaux_evenements);
  runApp(MyApp());
}