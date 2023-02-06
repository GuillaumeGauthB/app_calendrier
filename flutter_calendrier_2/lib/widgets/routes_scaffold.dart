import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/widgets/modify_event.dart';
import './refresh_data.dart';
import '../res/values.dart';
import './calendar.dart';
import 'package:get/get.dart';

import 'add_event.dart';
import 'app_settings.dart';
import 'navMenu.dart';
// import 'package:get/get.dart';

class CalendarBase extends StatelessWidget {
  const CalendarBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // an app bar at the top
      /*appBar: AppBar(
        // style of text set in text element
        title: Text(
          'Calendrier',
          style: TextStyle(color: colors["backgroundColor"],
              fontSize: 25),
        ),
        actions: const [
          RefreshData(),
        ],
        //backgroundColor: Theme.of(context).colorScheme.primary,
      ),*/

      body: Calendar(),//Get.put<Calendar>(Calendar()),
      bottomNavigationBar: NavMenu(),

      /*bottomNavigationBar: BottomAppBar(
        // style of text set in text element
        child: Text('Bottom app bar')

        //backgroundColor: Theme.of(context).colorScheme.primary,
      ),*/
    );
  }
}

class AppSettingsBase extends StatelessWidget {
  const AppSettingsBase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        // style of text set in text element
        title: Text(
          'Settings',
          style: TextStyle(color: colors["backgroundColor"],
              fontSize: 25),
        ),
        actions: const [
          RefreshData(),
        ],
        //backgroundColor: Theme.of(context).colorScheme.primary,
      ),*/

      body: AppSettings(),
      bottomNavigationBar: NavMenu(),
    );
  }
}


class ModifyEventBase extends StatelessWidget {
  const ModifyEventBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // style of text set in text element
        title: Text(
          'Calendrier',
          style: TextStyle(color: colors["backgroundColor"],
              fontSize: 25),
        ),
      ),
      body: ModifyEvent(Get.arguments),
    );
  }
}

