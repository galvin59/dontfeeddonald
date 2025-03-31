import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dont_feed_donald/l10n/l10n.dart'; // Import to access supported locales

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
      // User has explicitly set a language preference
      _locale = Locale(localeCode);
      notifyListeners();
    } else {
      // No saved preference, use device locale if supported
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      
      // Check if the device locale is supported by our app
      if (_isLocaleSupported(deviceLocale)) {
        _locale = deviceLocale;
        notifyListeners();
      }
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
    // Reset to device locale or fall back to English
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    _locale = _isLocaleSupported(deviceLocale) ? deviceLocale : const Locale('en');
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }
  
  // Helper method to check if a locale is supported
  bool _isLocaleSupported(Locale locale) {
    return L10n.all.contains(locale) || 
           L10n.all.any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }
}
