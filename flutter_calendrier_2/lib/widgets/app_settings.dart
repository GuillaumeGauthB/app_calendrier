import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/utils/FileUtils.dart';
import 'package:flutter_calendrier_2/widgets/refresh_data.dart';

import '../res/settings.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {

    //print(app_settings);
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
          ),

          child: TextButton(
              style: const ButtonStyle(
                overlayColor: MaterialStatePropertyAll<Color>(Colors.black),
              ),
              onPressed: () {
                // on sauvegarde les changements et rafrachit les evenements
                app_settings['last_refresh'] = DateTime.now().toString();
                const RefreshData();
                FileUtils.modifyFile(app_settings, fileName: 'settings.json', mode: 'settings');
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Mettre à jour les évènements'),
                      Icon(
                          Icons.refresh
                      )
                    ],
                  ),
                  Text('Dernière mise à jour: ${app_settings['last_refresh'].runtimeType == String ? app_settings['last_refresh'] : 'Jamais !'}')
                ],
              ),
          ),
        ),

        const SettingsThemeMode(),
          /*CheckboxListTile(
            title: const Text("Journée entière", style: TextStyle(), textWidthBasis: TextWidthBasis.longestLine),
            value: _valueCheckbox,
            onChanged: (bool? value) {
              setState(() {
                _valueCheckbox = value!;
              });
            },
          ),*/
        /*
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child:CheckboxListTile(
                title: Row(
                  children: const [
                    Text('Mettre à jour les évènements'),
                    RefreshData(),
                  ],
                ),
                // const Text("Journée entière", style: TextStyle(), textWidthBasis: TextWidthBasis.longestLine),
                value: _valueCheckbox,
                onChanged: (bool? value) {
                  setState(() {
                    _valueCheckbox = value!;
                  });
                },
              ),
            ),
          ]
        )*/
      ],//RefreshData(),
    );
  }
}

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
              hint: Text('theme'),

              onChanged: (Object? objet) {
                app_settings['theme_mode'] = objet;
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
                  child: Text('Téléphone'),
                )
              ],
            )
        );
  }
}

