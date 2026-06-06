import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settings = SettingsService();
  bool _initialized = false;

  bool get initialized => _initialized;
  SettingsService get settings => _settings;

  String get defaultCountryCode => _settings.defaultCountryCode;
  List<int> get defaultReminderDays => _settings.defaultReminderDays;
  String get currencySymbol => _settings.currencySymbol;
  String get businessName => _settings.businessName;
  String get displayName => _settings.displayName;

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    await _settings.initialize();
    _initialized = true;
    notifyListeners();
  }

  Future<void> setCountryCode(String code) async {
    await _settings.setDefaultCountryCode(code);
    notifyListeners();
  }

  Future<void> setReminderDays(List<int> days) async {
    await _settings.setDefaultReminderDays(days);
    notifyListeners();
  }

  Future<void> setCurrencySymbol(String symbol) async {
    await _settings.setCurrencySymbol(symbol);
    notifyListeners();
  }

  Future<void> setBusinessName(String name) async {
    await _settings.setBusinessName(name);
    notifyListeners();
  }

  Future<void> setDisplayName(String name) async {
    await _settings.setDisplayName(name);
    notifyListeners();
  }
}
