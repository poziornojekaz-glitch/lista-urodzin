import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';
import '../models/lista_item.dart';
import '../models/powiadomienia_settings.dart';
import '../utils/translations.dart';

class NotificationService {
  static const String channelKey = 'urodziny_channel';

  /// Inicjalizacja kanału powiadomień
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // Domyślna ikona aplikacji z manifestu
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: 'Urodziny',
          channelDescription: 'Kanał powiadomień o urodzinach',
          defaultColor: const Color(0xFF9D50BB),
          ledColor: const Color(0xFFFFFFFF),
          importance: NotificationImportance.Max,
          channelShowBadge: true,
        )
      ],
      debug: false,
    );
  }

  /// Prośba o uprawnienia do wysyłania powiadomień
  static Future<bool> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  /// Główna funkcja planowania powiadomień
  static Future<void> zaplanujUrodzinyFinal(
    List<ListaItem> listaUrodzin,
    PowiadomieniaSettings ustawienia,
    String lang,
  ) async {
    // 1. Czyścimy stare harmonogramy
    await AwesomeNotifications().cancelAllSchedules();

    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();

    String txtDzisiaj = AppTranslations.tr('reminder_today', lang);
    String txtJutro = AppTranslations.tr('reminder_tomorrow', lang);

    for (int i = 0; i < listaUrodzin.length; i++) {
      var osoba = listaUrodzin[i];

      // Jeśli wyłączono powiadomienia dla tej osoby, pomijamy
      if (osoba.czyPowiadamiac == false) continue;

      String imie = osoba.tekst.isNotEmpty ? osoba.tekst : '???';
      DateTime? dataUro = osoba.datazapisz;
      int baseId = osoba.id;

      if (dataUro == null) continue;

      String dataTekst = DateFormat("d MMMM", lang).format(dataUro);
      String trescPowiadomienia = "$imie, $dataTekst";

      // --- POWIADOMIENIE: W DNIU URODZIN ---
      if (ustawienia.alertWDniu) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: (baseId % 100000) + 100000,
            channelKey: channelKey,
            title: txtDzisiaj,
            body: trescPowiadomienia,
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            month: dataUro.month,
            day: dataUro.day,
            hour: ustawienia.godzinaWDniu,
            minute: 0,
            second: 0,
            millisecond: 0,
            repeats: true, // Powtarzaj co ROK
            allowWhileIdle: true,
            preciseAlarm: true,
            timeZone: localTimeZone,
          ),
        );
      }

      // --- POWIADOMIENIE: DZIEŃ PRZED ---
      if (ustawienia.alertDzienPrzed) {
        DateTime dataPomocnicza = DateTime(2024, dataUro.month, dataUro.day);
        DateTime dzienWczesniej =
            dataPomocnicza.subtract(const Duration(days: 1));

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: (baseId % 100000) + 200000,
            channelKey: channelKey,
            title: txtJutro,
            body: trescPowiadomienia,
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            month: dzienWczesniej.month,
            day: dzienWczesniej.day,
            hour: ustawienia.godzinaDzienPrzed,
            minute: 0,
            second: 0,
            millisecond: 0,
            repeats: true, // Powtarzaj co ROK
            allowWhileIdle: true,
            preciseAlarm: true,
            timeZone: localTimeZone,
          ),
        );
      }
    }
  }
}
