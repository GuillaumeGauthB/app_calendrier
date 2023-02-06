import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../res/theme_data.dart';
import './modify_event.dart';
import './routes_scaffold.dart';

class MyApp extends StatelessWidget {
  //const MyApp({super.key});
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //print('dark mode: ${isDarkTheme}');
    return GetMaterialApp(
        title: 'Calendrier',
        theme: AppTheme.getLightMode,
        // darkTheme: ThemeData(
        //   primarySwatch: Colors.blueGrey,
        // ),
        // themeMode: ThemeMode.dark,

        initialRoute: '/calendrier',
        getPages: [
          GetPage(name: '/calendrier', page: () => const CalendarBase()),
          GetPage(name: '/calendrier/modifier', page: () => const ModifyEventBase()),
          GetPage(name: '/settings', page: () => const AppSettingsBase()),
        ],

        // Désactiver la bannière
        debugShowCheckedModeBanner: false,
        // home: const Calendar(),
      //const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}