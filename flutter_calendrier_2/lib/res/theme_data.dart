import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/res/values.dart';

const ColorScheme lightColorScheme = ColorScheme(
                  brightness: Brightness.light,
                  primary: Color(0xFF1D3557),
                  background: Color(0xFFEAF0F8),
                  // background: Color(0xFF1D3557),
                  onBackground: Colors.black,
                  onPrimary: Color(0xFFEAF0F8),
                  secondary: Color(0xFF1D3557),
                  // secondary: Color(0xFF112034),
                  onSecondary: Colors.white,
                  error: Colors.red,
                  onError: Colors.deepOrange,
                  onSurface: Colors.black,
                  surface: Colors.white,
              );



class AppTheme {
  static ThemeData get getLightMode {
    return ThemeData(
      // This is the theme of your application.
      //
      // Try running your application with "flutter run". You'll see the
      // application has a blue toolbar. Then, without quitting the app, try
      // changing the primarySwatch below to Colors.green and then invoke
      // "hot reload" (press "r" in the console where you ran "flutter run",
      // or simply save your changes to "hot reload" in a Flutter IDE).
      // Notice that the counter didn't reset back to zero; the application
      // is not restarted.
      //primarySwatch: isDarkTheme == true ? Colors.pink : Colors.red,

      appBarTheme: const AppBarTheme(
        color: Color(0xFF1D3557),
      ),

      colorScheme: lightColorScheme,
      primaryColor: lightColorScheme.primary,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: lightColorScheme.primary),
        titleMedium: TextStyle(color: lightColorScheme.primary),
        labelMedium: TextStyle(
          color: lightColorScheme.primary,
          decorationColor: lightColorScheme.primary,
          /*foreground: Paint(
            color: lightColorScheme.primary
          )*/
        ),
        bodyLarge: TextStyle(color: lightColorScheme.onPrimary),
        // bodyText1: TextStyle(color: lightColorScheme.primary),
        // bodyText2: TextStyle(color: lightColorScheme.onPrimary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        iconColor: lightColorScheme.primary,
        // hintText: 'Entrer l\'information ici',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lightColorScheme.primary),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: lightColorScheme.primary),
        ),

      ),

      backgroundColor: lightColorScheme.background,

      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(

            backgroundColor: MaterialStatePropertyAll<Color>(lightColorScheme.background),
            foregroundColor: MaterialStatePropertyAll<Color>(lightColorScheme.secondary),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: lightColorScheme.onSecondary)
              )
            )
          )
      ),

      buttonTheme: const ButtonThemeData(
          buttonColor: Colors.black,
          splashColor: Colors.black,
          //buttonColor: Colors.black,
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: Colors.black,
            background: Colors.black,
            onBackground: Colors.black,
            onPrimary: Colors.white,
            secondary: Colors.white,
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.deepOrange,
            onSurface: Colors.black,
            surface: Colors.white,
          )
      ),

      /*colorScheme: ColorScheme(
          primary: Colors.black,
        ),*/

      brightness: Brightness.light,

      /*textTheme: const TextTheme(
          bodyMedium: Colors.black,
        ),*/
    );
  }
}