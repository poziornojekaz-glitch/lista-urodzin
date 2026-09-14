import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
    try {
      await NotificationService.zaplanujUrodzinyFinal(
        _urodzinyList,
        _powiadomienia,
        _wybranyJezyk,
      );
    } catch (_) {
      // Ignorujemy błędy, aby interfejs zawsze działał płynnie
    }
  }

  /// Eksport pełnej kopii zapasowej do pliku JSON i udostępnienie
  Future<void> exportBackupFile() async {
    try {
      final Map<String, dynamic> backupData = {
        'version': 1,
        'app': 'lista_urodzin',
        'exportDate': DateTime.now().toIso8601String(),
        'urodziny': _urodzinyList.map((e) => e.toJson()).toList(),
        'powiadomienia': _powiadomienia.toJson(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/kopia_urodzin.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Kopia zapasowa - Lista urodzin',
        text: 'Kopia zapasowa listy urodzin.',
      );
    } catch (e) {
      debugPrint('Błąd eksportu kopii zapasowej: $e');
      rethrow;
    }
  }

  /// Import danych z tekstu JSON (z pliku lub schowka)
  /// Zwraca liczbę dodanych nowych pozycji
  Future<int> importFromBackupJson(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString.trim());
      List<dynamic> listToImport = [];

      if (decoded is List) {
        listToImport = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('urodziny') && decoded['urodziny'] is List) {
          listToImport = decoded['urodziny'] as List<dynamic>;
        }
        if (decoded.containsKey('powiadomienia') &&
            decoded['powiadomienia'] is Map<String, dynamic>) {
          try {
            _powiadomienia = PowiadomieniaSettings.fromJson(
                decoded['powiadomienia'] as Map<String, dynamic>);
            await StorageService.saveSettings(_powiadomienia);
          } catch (_) {}
        }
      } else {
        throw const FormatException('Nieobsługiwany format pliku');
      }

      int dodanoLicznik = 0;
      for (var itemMap in listToImport) {
        if (itemMap is Map<String, dynamic>) {
          final newItem = ListaItem.fromJson(itemMap);
          bool duplikat = CustomFunctions.czyIstniejeDuplikatV3(
            _urodzinyList,
            newItem.tekst,
            newItem.datazapisz,
            -1,
          );

          if (!duplikat && newItem.tekst.trim().isNotEmpty) {
            newItem.id = DateTime.now().millisecondsSinceEpoch + dodanoLicznik;
            _urodzinyList.add(newItem);
            dodanoLicznik++;
          }
        }
      }

      if (dodanoLicznik > 0) {
        _urodzinyList = CustomFunctions.sortujUrodziny(_urodzinyList);
        await StorageService.saveUrodziny(_urodzinyList);
        notifyListeners();
        await reschedulNotifications();
      }

      return dodanoLicznik;
    } catch (e) {
      debugPrint('Błąd importu: $e');
      rethrow;
    }
  }

  /// Otwiera selektor plików i wczytuje kopię
  Future<int?> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final picked = result.files.single;
        String? content;
        if (picked.bytes != null) {
          content = utf8.decode(picked.bytes!);
        } else if (picked.path != null) {
          final file = File(picked.path!);
          content = await file.readAsString();
        }

        if (content != null && content.trim().isNotEmpty) {
          return await importFromBackupJson(content);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Błąd wczytywania pliku: $e');
      rethrow;
    }
  }
}
