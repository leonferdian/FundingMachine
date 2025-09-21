import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  static const String _languageCodeKey = 'languageCode';
  
  // Supported locales
  static const Locale enLocale = Locale('en', 'US');
  static const Locale idLocale = Locale('id', 'ID');
  
  // Default locale
  static const Locale defaultLocale = enLocale;
  
  // List of supported locales
  static const List<Locale> supportedLocales = [
    enLocale,
    idLocale,
  ];
  
  // Current locale
  late Locale _locale;
  
  // Stream controller for locale changes
  final _localeController = StreamController<Locale>.broadcast();
  
  // Getter for current locale
  Locale get locale => _locale;
  
  // Stream of locale changes
  Stream<Locale> get onLocaleChanged => _localeController.stream;
  
  // Private constructor
  LocalizationService._internal();
  
  // Factory constructor
  factory LocalizationService() => _instance;
  
  // Initialize the service
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey) ?? defaultLocale.languageCode;
    _instance._locale = Locale(languageCode);
    
    // Validate if the saved locale is supported
    if (!supportedLocales.any((locale) => locale.languageCode == _instance._locale.languageCode)) {
      _instance._locale = defaultLocale;
      await prefs.setString(_languageCodeKey, _instance._locale.languageCode);
    }
  }
  
  // Change the app's locale
  Future<void> setLocale(Locale newLocale) async {
    if (!supportedLocales.any((locale) => locale.languageCode == newLocale.languageCode)) {
      throw Exception('Locale $newLocale is not supported');
    }
    
    _locale = newLocale;
    _localeController.add(_locale);
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, _locale.languageCode);
  }
  
  // Check if the current locale is RTL
  bool isRTL() {
    return _locale.languageCode == 'ar' || _locale.languageCode == 'he';
  }
  
  // Dispose resources
  void dispose() {
    _localeController.close();
  }
  
  // Helper method to get the current locale's language name
  String getCurrentLanguageName() {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return 'English';
    }
  }
  
  // Helper method to get the language code
  static String getLanguageCode() {
    return _instance._locale.languageCode;
  }
  
  // Helper method to get the current locale
  static Locale get currentLocale => _instance._locale;
  
  // Helper method to get supported locales
  static List<Locale> get supportedLocalesList => supportedLocales;
}
