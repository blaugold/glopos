import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Brightness? _overriddenBrightness;

  Brightness get platformBrightness => _platformBrightness;
  Brightness _platformBrightness = Brightness.light;

  set platformBrightness(Brightness platformBrightness) {
    if (_platformBrightness != platformBrightness) {
      _platformBrightness = platformBrightness;
      notifyListeners();
    }
  }

  bool get darkMode =>
      (_overriddenBrightness ?? _platformBrightness) == Brightness.dark;

  set darkMode(bool darkMode) {
    Brightness? overriddenBrightness =
        darkMode ? Brightness.dark : Brightness.light;

    if (_platformBrightness == overriddenBrightness) {
      overriddenBrightness = null;
    }

    if (_overriddenBrightness != overriddenBrightness) {
      _overriddenBrightness = overriddenBrightness;
      notifyListeners();
    }
  }

  ThemeMode get themeMode => darkMode ? ThemeMode.dark : ThemeMode.light;
}
