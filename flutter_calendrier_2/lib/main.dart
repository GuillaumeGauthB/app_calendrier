import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_calendrier_2/utils/SharedPreferencesUtils.dart';
import 'widgets/calendar.dart';
import 'res/values.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'widgets/refresh_data.dart';
import '../utils/FileUtils.dart';
import '../res/events.dart';

/*Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}*/
bool isDarkTheme = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // dark theme
  isDarkTheme = await SharedPreferencesValues().getTheme;
  // tableau des evenements
  tableaux_evenements = jsonDecode(await FileUtils.readFromFile);

  await Firebase.initializeApp();
  runApp(MyApp());
}