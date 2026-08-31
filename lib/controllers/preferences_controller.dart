import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class PreferencesController extends ChangeNotifier {
  PreferencesController(this.service) {
    _darkMode = service.getDarkMode();
    _name = service.getName();
    _welcomeSeen = service.getWelcomeSeen();
  }

  final PreferencesService service;

  bool _darkMode = false;
  String _name = '';
  bool _welcomeSeen = false;

  bool get darkMode => _darkMode;
  String get name => _name;
  bool get welcomeSeen => _welcomeSeen;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await service.setDarkMode(value);
  }

  Future<void> setName(String value) async {
    _name = value.trim();
    notifyListeners();
    await service.setName(_name);
  }

  Future<void> completeWelcome() async {
    _welcomeSeen = true;
    notifyListeners();
    await service.setWelcomeSeen(true);
  }
}
