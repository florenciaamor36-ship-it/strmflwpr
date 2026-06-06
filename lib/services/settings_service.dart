import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsService {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) throw StateError('SettingsService not initialized');
    return _prefs!;
  }

  // ─── Country Code ───────────────────────────────
  String get defaultCountryCode =>
      prefs.getString(AppConstants.prefDefaultCountryCode) ??
      AppConstants.defaultCountryCode;

  Future<void> setDefaultCountryCode(String code) async {
    await prefs.setString(AppConstants.prefDefaultCountryCode, code);
  }

  // ─── Reminder Days ──────────────────────────────
  List<int> get defaultReminderDays {
    final stored = prefs.getString(AppConstants.prefDefaultReminderDays);
    if (stored == null) return AppConstants.defaultReminderDays;
    return stored
        .split(',')
        .map((s) => int.tryParse(s.trim()) ?? 0)
        .where((d) => d > 0)
        .toList();
  }

  Future<void> setDefaultReminderDays(List<int> days) async {
    await prefs.setString(
        AppConstants.prefDefaultReminderDays, days.join(','));
  }

  // ─── Currency Symbol ────────────────────────────
  String get currencySymbol =>
      prefs.getString(AppConstants.prefCurrencySymbol) ??
      AppConstants.defaultCurrencySymbol;

  Future<void> setCurrencySymbol(String symbol) async {
    await prefs.setString(AppConstants.prefCurrencySymbol, symbol);
  }

  // ─── Business Name ──────────────────────────────
  String get businessName =>
      prefs.getString(AppConstants.prefBusinessName) ??
      AppConstants.defaultBusinessName;

  Future<void> setBusinessName(String name) async {
    await prefs.setString(AppConstants.prefBusinessName, name);
  }

  // ─── Display Name ───────────────────────────────
  String get displayName =>
      prefs.getString(AppConstants.prefDisplayName) ?? '';

  Future<void> setDisplayName(String name) async {
    await prefs.setString(AppConstants.prefDisplayName, name);
  }

  // ─── Theme ──────────────────────────────────────
  ThemeMode get themeMode {
    final stored = prefs.getString(AppConstants.prefThemeMode);
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await prefs.setString(AppConstants.prefThemeMode, value);
  }

  Future<void> clearAll() async {
    await prefs.clear();
  }
}
