import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lista_item.dart';
import '../models/powiadomienia_settings.dart';

class StorageService {
  static const String _keyUrodziny = 'urodziny_lista_v1';
  static const String _keyPowiadomienia = 'powiadomienia_settings_v1';
  static const String _keyJezyk = 'wybrany_jezyk_v1';

  /// Zapisuje listę urodzin
  static Future<void> saveUrodziny(List<ListaItem> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(lista.map((e) => e.toJson()).toList());
    await prefs.setString(_keyUrodziny, jsonString);
  }

  /// Wczytuje listę urodzin
  static Future<List<ListaItem>> loadUrodziny() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUrodziny);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => ListaItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Zapisuje ustawienia powiadomień
  static Future<void> saveSettings(PowiadomieniaSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_keyPowiadomienia, jsonString);
  }

  /// Wczytuje ustawienia powiadomień
  static Future<PowiadomieniaSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyPowiadomienia);
    if (jsonString == null || jsonString.isEmpty) {
      return PowiadomieniaSettings();
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return PowiadomieniaSettings.fromJson(decoded);
    } catch (e) {
      return PowiadomieniaSettings();
    }
  }

  /// Zapisuje wybrany język
  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJezyk, lang);
  }

  /// Wczytuje wybrany język
  static Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyJezyk) ?? 'pl';
  }
}
