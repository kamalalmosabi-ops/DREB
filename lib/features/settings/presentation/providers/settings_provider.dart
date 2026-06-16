import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsProvider with ChangeNotifier {
  bool _isDark = false;
  Locale _locale = const Locale('ar');

  bool get isDark => _isDark;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    _locale = Locale(prefs.getString('lang') ?? 'ar');
    notifyListeners();
  }

  void toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', _isDark);
    notifyListeners();
  }

  void setLocale(String langCode) async {
    _locale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lang', langCode);
    notifyListeners();
  }
}