import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/utils/file_utils.dart';
import 'package:flutter_calendrier_2/widgets/refresh_data.dart';
import 'package:get/get.dart';
import '../res/settings.dart';
import 'MyApp.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    // print(listeHoraires);
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          /**
           * Debut des settings
           */
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1)),
            ),
            /**
             * Bouton permettant de synchroniser la DB
             */
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.onBackground),
              ),
              onPressed: () {
                // on sauvegarde les changements et rafrachit les evenements
                app_settings['last_refresh'] = DateTime.now().toString();
                RefreshData.getData();
                FileUtils.modifyFile(
                  itemToAdd: app_settings,
                  fileName: 'settings.json',
                  mode: OperationType.settings
                );
                setState(() {});
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Derni??re mise ?? jour: ${app_settings['last_refresh'].runtimeType == String ? app_settings['last_refresh'].substring(0, app_settings['last_refresh'].indexOf('.')) : 'Jamais !'}'),
                      const Icon(
                          Icons.refresh
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          /**
           * Input permettant de choisir le theme
           */
          const SettingsThemeMode(),

          /**
           * Lien permettant de cr??er et de lister des horaires
           */
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1)),
            ),
            /**
             * Bouton permettant de voir et modifier les horaires existant
             */
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.onBackground),
              ),
              onPressed: () {
                Get.toNamed("/settings/horaires");
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Cr??er des horaires'),
                      Icon(
                          Icons.arrow_forward_outlined
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

        ],//RefreshData(),
      ),
    );
  }
}

/// La classe du theme
class SettingsThemeMode extends StatefulWidget {
  const SettingsThemeMode({Key? key}) : super(key: key);

  @override
  State<SettingsThemeMode> createState() => _SettingsThemeModeState();
}

class _SettingsThemeModeState extends State<SettingsThemeMode> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DropdownButtonFormField(
            onChanged: (Object? objet) async {
              app_settings['theme_mode'] = objet;
              await FileUtils.modifyFile(
                itemToAdd: app_settings,
                fileName: 'settings.json',
                mode: OperationType.settings
              );
              runApp(MyApp());
            },

            decoration: const InputDecoration(
              label: Text('Theme')
            ),

            value: (app_settings['theme_mode'].runtimeType != Null ? app_settings['theme_mode'] : 'phone_pref'),

            items: const [
              DropdownMenuItem(
                value: 'dark',
                child: Text('Sombre'),
              ),
              DropdownMenuItem(
                value: 'light',
                child: Text('Clair'),
              ),
              DropdownMenuItem(
                value: 'phone_pref',
                child: Text('T??l??phone'),
              )
            ],
          )
      );
  }
}

