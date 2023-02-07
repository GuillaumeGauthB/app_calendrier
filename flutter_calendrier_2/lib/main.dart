import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_calendrier_2/utils/SharedPreferencesUtils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/FileUtils.dart';
import '../res/events.dart';
import '../res/settings.dart';
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
  // dark theme
  isDarkTheme = await SharedPreferencesValues().getTheme;
  // tableau des evenements
  //await FileUtils.saveToFile('{\'hihiha\': \'hihiha\'}');
  print(await FileUtils.init);
  app_settings = jsonDecode(await FileUtils.readFromFile(fileName: 'settings.json'));
  listeHoraires = jsonDecode(await FileUtils.readFromFile(fileName: 'horaires.json'));
  tableaux_evenements = jsonDecode(await FileUtils.readFromFile());
  //print(tableaux_evenements.runtimeType);
  //testJSON.runtimeType = tableaux_evenements.runtimeType;
  //print(tableaux_evenements);
  await Firebase.initializeApp();
  runApp(MyApp());
}