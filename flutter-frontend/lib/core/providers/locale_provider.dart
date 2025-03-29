import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _localeKey = 'locale';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localeCode = prefs.getString(_localeKey);
    
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en');
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }
}
