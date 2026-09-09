import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this.preferences);

  final SharedPreferences preferences;

  static const String darkModeKey = 'dark_mode';
  static const String nameKey = 'client_name';
  static const String welcomeSeenKey = 'eivet_welcome_seen';

  bool getDarkMode() => preferences.getBool(darkModeKey) ?? false;
  String getName() => preferences.getString(nameKey) ?? '';
  bool getWelcomeSeen() => preferences.getBool(welcomeSeenKey) ?? false;

  Future<void> setDarkMode(bool value) {
    return preferences.setBool(darkModeKey, value);
  }

  Future<void> setName(String value) {
    return preferences.setString(nameKey, value.trim());
  }

  Future<void> setWelcomeSeen(bool value) {
    return preferences.setBool(welcomeSeenKey, value);
  }
}
