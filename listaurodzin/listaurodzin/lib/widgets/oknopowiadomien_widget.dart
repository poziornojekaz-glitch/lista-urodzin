import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/powiadomienia_settings.dart';
import '../services/notification_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/translations.dart';
import 'hour_picker.dart';

class OknopowiadomienWidget extends StatefulWidget {
  const OknopowiadomienWidget({super.key});

  @override
  State<OknopowiadomienWidget> createState() => _OknopowiadomienWidgetState();
}

class _OknopowiadomienWidgetState extends State<OknopowiadomienWidget> {
  late PowiadomieniaSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = context.read<AppState>().powiadomienia.copyWith();
  }

  void _showNotificationAlert(bool isEnabled, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          isEnabled
              ? AppTranslations.tr('notifications_enabled', lang)
              : AppTranslations.tr('notifications_disabled', lang),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTranslations.tr('ok', lang)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.wybranyJezyk;
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.95,
          height: size.height * 0.60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, AppTheme.background],
              stops: [0.0, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Column(
              children: [
                // Przycisk zamknięcia (krzyżyk)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        await NotificationService.requestPermission();
                        if (context.mounted) {
                          await context
                              .read<AppState>()
                              .updatePowiadomienia(_currentSettings);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                // Tytuł
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    AppTranslations.tr('settings_notifications_title', lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D7C70),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Dwie kolumny obok siebie
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // --- LEWA KOLUMNA: DZIEŃ PRZED ---
                      Expanded(
                        child: Column(
                          children: [
                            // Karta włącznika
                            Container(
                              height: 58,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primary, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x15000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _currentSettings.alertDzienPrzed,
                                    activeColor: AppTheme.primary,
                                    onChanged: (val) {
                                      final newVal = val ?? false;
                                      setState(() {
                                        _currentSettings.alertDzienPrzed = newVal;
                                      });
                                      _showNotificationAlert(newVal, lang);
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppTranslations.tr('day_before_event', lang),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Karta z wyborem godziny
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primary, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x15000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: HourPicker(
                                    initialHour: _currentSettings.godzinaDzienPrzed,
                                    textColor: const Color(0xFF15766E),
                                    onHourChanged: (pickedHour) {
                                      setState(() {
                                        _currentSettings.godzinaDzienPrzed = pickedHour;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // --- PRAWA KOLUMNA: W DNIU WYDARZENIA ---
                      Expanded(
                        child: Column(
                          children: [
                            // Karta włącznika
                            Container(
                              height: 58,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.primary, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x15000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _currentSettings.alertWDniu,
                                    activeColor: AppTheme.primary,
                                    onChanged: (val) {
                                      final newVal = val ?? false;
                                      setState(() {
                                        _currentSettings.alertWDniu = newVal;
                                      });
                                      _showNotificationAlert(newVal, lang);
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppTranslations.tr('on_event_day', lang),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Karta z wyborem godziny
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primary, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x15000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: HourPicker(
                                    initialHour: _currentSettings.godzinaWDniu,
                                    textColor: const Color(0xFF15766E),
                                    onHourChanged: (pickedHour) {
                                      setState(() {
                                        _currentSettings.godzinaWDniu = pickedHour;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
