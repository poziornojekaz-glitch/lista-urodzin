import 'package:flutter/material.dart';
import '../models/lista_item.dart';
import '../models/powiadomienia_settings.dart';
import '../models/share_item.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/custom_functions.dart';

class AppState extends ChangeNotifier {
  List<ListaItem> _urodzinyList = [];
  PowiadomieniaSettings _powiadomienia = PowiadomieniaSettings();
  String _wybranyJezyk = 'pl';
  List<ListaDoUdostepnienia> _tymczasowaListaShare = [];
  bool _isInitialized = false;

  List<ListaItem> get urodzinyList => _urodzinyList;
  PowiadomieniaSettings get powiadomienia => _powiadomienia;
  String get wybranyJezyk => _wybranyJezyk;
  List<ListaDoUdostepnienia> get tymczasowaListaShare => _tymczasowaListaShare;
  bool get isInitialized => _isInitialized;

  /// Inicjalizacja stanu z pamięci lokalnej
  Future<void> initialize() async {
    _urodzinyList = await StorageService.loadUrodziny();
    _powiadomienia = await StorageService.loadSettings();
    _wybranyJezyk = await StorageService.loadLanguage();

    // Sortujemy urodziny na start
    _urodzinyList = CustomFunctions.sortujUrodziny(_urodzinyList);
    _isInitialized = true;
    notifyListeners();

    // Planujemy powiadomienia
    await reschedulNotifications();
  }

  /// Zmiana wybranego języka
  Future<void> setLanguage(String lang) async {
    _wybranyJezyk = lang;
    await StorageService.saveLanguage(lang);
    notifyListeners();
    await reschedulNotifications();
  }

  /// Dodanie nowego wpisu urodzin
  Future<void> addUrodziny(ListaItem item) async {
    _urodzinyList.insert(0, item);
    _urodzinyList = CustomFunctions.sortujUrodziny(_urodzinyList);
    await StorageService.saveUrodziny(_urodzinyList);
    notifyListeners();
    await reschedulNotifications();
  }

  /// Aktualizacja istniejącego wpisu
  Future<void> updateUrodziny(int index, ListaItem item) async {
    if (index >= 0 && index < _urodzinyList.length) {
      _urodzinyList[index] = item;
      _urodzinyList = CustomFunctions.sortujUrodziny(_urodzinyList);
      await StorageService.saveUrodziny(_urodzinyList);
      notifyListeners();
      await reschedulNotifications();
    }
  }

  /// Usunięcie wpisu
  Future<void> removeUrodziny(int index) async {
    if (index >= 0 && index < _urodzinyList.length) {
      _urodzinyList.removeAt(index);
      await StorageService.saveUrodziny(_urodzinyList);
      notifyListeners();
      await reschedulNotifications();
    }
  }

  /// Włączenie/wyłączenie powiadomień dla konkretnej osoby
  Future<void> togglePowiadamiac(int index, bool newValue) async {
    if (index >= 0 && index < _urodzinyList.length) {
      _urodzinyList[index].czyPowiadamiac = newValue;
      await StorageService.saveUrodziny(_urodzinyList);
      notifyListeners();
      await reschedulNotifications();
    }
  }

  /// Aktualizacja ustawień powiadomień
  Future<void> updatePowiadomienia(PowiadomieniaSettings newSettings) async {
    _powiadomienia = newSettings;
    await StorageService.saveSettings(_powiadomienia);
    notifyListeners();
    await reschedulNotifications();
  }

  /// Przygotowanie listy do udostępnienia
  void prepareShareList() {
    _tymczasowaListaShare = CustomFunctions.przepiszNaListeShare(_urodzinyList);
    notifyListeners();
  }

  /// Zmiana zaznaczenia w liście udostępniania
  void toggleShareItem(int index, bool newValue) {
    if (index >= 0 && index < _tymczasowaListaShare.length) {
      _tymczasowaListaShare[index].czyprzekazac = newValue;
      notifyListeners();
    }
  }

  /// Ponowne zaplanowanie powiadomień w systemie
  Future<void> reschedulNotifications() async {
    await NotificationService.zaplanujUrodzinyFinal(
      _urodzinyList,
      _powiadomienia,
      _wybranyJezyk,
    );
  }
}
