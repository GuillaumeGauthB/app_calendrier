import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import '../res/theme_data.dart';
import '../res/settings.dart';
import './routes_scaffold.dart';

class MyApp extends StatelessWidget {
  late ThemeMode currentThemeMode; // le theme present de l'application

  @override
  Widget build(BuildContext context) {
    // Set up du theme
    if(app_settings['theme_mode'] == 'dark'){
      currentThemeMode = ThemeMode.dark;
    } else if (app_settings['theme_mode'] == 'light'){
      currentThemeMode = ThemeMode.light;
    } else {
      currentThemeMode = ThemeMode.system;
    }

    return GetMaterialApp(
        title: 'Calendrier',
        theme: AppTheme.getLightMode,
        darkTheme: AppTheme.getDarkMode,
        themeMode: currentThemeMode,

        initialRoute: '/calendrier',
        getPages: [
          GetPage(name: '/calendrier', page: () => const CalendarBase()),
          //GetPage(name: '/calendrier/modifier', page: () => const ModifyEventBase()),
          GetPage(name: '/settings', page: () => const AppSettingsBase()),
          GetPage(name: '/settings/horaires', page: () => const AddScheduleBase()),
        ],

        // Désactiver la bannière
        debugShowCheckedModeBanner: false,
        // home: const Calendar(),
      //const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}