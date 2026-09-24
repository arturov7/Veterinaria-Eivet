import 'package:flutter/material.dart';

import '../../services/movil/preferences_service.dart';

class PreferencesController extends ChangeNotifier {
  PreferencesController(this.service) {
    _darkMode = service.getDarkMode();
    _name = '';
    _welcomeSeen = service.getWelcomeSeen();
  }

  final PreferencesService service;

  bool _darkMode = false;
  String _name = '';
  String? _userId;
  bool _welcomeSeen = false;

  bool get darkMode => _darkMode;
  String get name => _name;
  void switchUser(String? userId, {String? defaultName}) {
    if (_userId == userId) return;
    _userId = userId;
    _name = service.getName(userId);
    if (_name.isEmpty) _name = defaultName?.trim() ?? '';
    notifyListeners();
  }
  bool get welcomeSeen => _welcomeSeen;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await service.setDarkMode(value);
  }

  Future<void> setName(String value) async {
    final userId = _userId;
    if (userId == null) throw StateError('No hay una sesión activa.');
    _name = value.trim();
    notifyListeners();
    await service.setName(userId, _name);
  }

  Future<void> completeWelcome() async {
    _welcomeSeen = true;
    notifyListeners();
    await service.setWelcomeSeen(true);
  }
}
