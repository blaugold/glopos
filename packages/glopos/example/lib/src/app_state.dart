import 'dart:ui';

import 'package:flutter/widgets.dart';

class AppState extends ChangeNotifier
    with
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  AppState() {
    WidgetsBinding.instance!.addObserver(this);
  }

  Brightness _platformBrightness =
      PlatformDispatcher.instance.platformBrightness;
  Brightness? _overriddenBrightness;

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

  @override
  void didChangePlatformBrightness() {
    final platformBrightness = PlatformDispatcher.instance.platformBrightness;
    if (_platformBrightness != platformBrightness) {
      _platformBrightness = platformBrightness;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
