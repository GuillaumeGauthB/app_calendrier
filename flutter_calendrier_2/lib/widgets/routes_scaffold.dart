import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/widgets/modify_event.dart';
import '../res/values.dart';
import './calendar.dart';
import 'package:get/get.dart';
import 'app_settings.dart';
import 'list_schedule.dart';
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

      body: const Calendar(),//Get.put<Calendar>(Calendar()),
      bottomNavigationBar: NavMenu(),
    );
  }
}

class AppSettingsBase extends StatelessWidget {
  const AppSettingsBase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AppSettings(),
      bottomNavigationBar: NavMenu(),
    );
  }
}

class AddScheduleBase extends StatelessWidget {
  const AddScheduleBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const ListSchedule(),
        bottomNavigationBar: NavMenu(),
        /*bottomNavigationBar: AppBar(
          title: Text(
            'Horaires',
            style: TextStyle(color: colors["backgroundColor"],
                fontSize: 25),
          ),
        ),*/
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

