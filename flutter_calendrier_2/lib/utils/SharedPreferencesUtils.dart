import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesValues {
  // dunno pk celle la est comme ca mais bon
  static const THEME_STATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  // getter du theme
  Future<bool> get getTheme async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }
}


class DarkThemeProvider extends SharedPreferencesValues with ChangeNotifier{
// dunno si ca va changer qqch de le mettre enfant
//class DarkThemeProvider with ChangeNotifier{
  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    setDarkTheme(value);
    notifyListeners();
  }
}