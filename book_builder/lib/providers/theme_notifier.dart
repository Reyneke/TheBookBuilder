import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(
    ThemeMode.dark,
  );

  ValueNotifier<ThemeMode> get themeModeNotifier => _themeModeNotifier;
  void setThemeModeNotifier(ThemeMode newMode) {
    _themeModeNotifier = ValueNotifier(newMode);
  }
}
