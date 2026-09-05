import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lista_item.dart';
import '../services/notification_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/translations.dart';
import '../widgets/edytorwiersza_widget.dart';
import '../widgets/instrukcja_widget.dart';
import '../widgets/oknopowiadomien_widget.dart';
import '../widgets/oknoprzekazu_widget.dart';
import '../widgets/pusty_widget.dart';
import '../widgets/wiersz1_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.wybranyJezyk;
    final lista = state.urodzinyList;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // --- GÓRNY PASEK: DZWONEK, LOGO, KOPERTA ---
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.topGradient,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x30000000),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Przycisk powiadomień (Dzwonek)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (dialogCtx) => const OknopowiadomienWidget(),
                            );
                          },
                        ),
                      ),

                      // Środek - Logo / Ikona kalendarza
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cake_outlined, color: Colors.white, size: 28),
                            SizedBox(width: 6),
                            Icon(Icons.calendar_month, color: Colors.white, size: 28),
                          ],
                        ),
                      ),

                      // Przycisk udostępniania (Koperta)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () async {
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (alertCtx) => AlertDialog(
                                title: Text(AppTranslations.tr('share_list', lang)),
                                content: Text(AppTranslations.tr('share_confirm', lang)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(alertCtx, false),
                                    child: Text(AppTranslations.tr('back', lang)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(alertCtx, true),
                                    child: Text(AppTranslations.tr('ok', lang)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              context.read<AppState>().prepareShareList();
                              await showDialog(
                                context: context,
                                builder: (dialogCtx) => const OknoprzekazuWidget(),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // --- DRUGI PASEK: WYBÓR JĘZYKA ORAZ PRZYCISK INFO ---
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.languageGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Dropdown wyboru języka
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6EE1D4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white70),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: lang,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF15766E),
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15766E),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'pl', child: Text('PL  🇵🇱')),
                              DropdownMenuItem(value: 'en', child: Text('EN  🇬🇧')),
                              DropdownMenuItem(value: 'de', child: Text('DE  🇩🇪')),
                              DropdownMenuItem(value: 'ru', child: Text('RU  🇷🇺')),
                            ],
                            onChanged: (newLang) {
                              if (newLang != null) {
                                context.read<AppState>().setLanguage(newLang);
                              }
                            },
                          ),
                        ),
                      ),

                      // Przycisk "Info" (Instrukcja)
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (dialogCtx) => const InstrukcjaWidget(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6EE1D4),
                            foregroundColor: const Color(0xFF15766E),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.white70),
                            ),
                          ),
                          child: Text(
                            AppTranslations.tr('info', lang),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tytuł "Kalendarz wydarzeń"
                Text(
                  AppTranslations.tr('calendar_title', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15998C),
                  ),
                ),

                const SizedBox(height: 12),

                // Lista urodzin
                Expanded(
                  child: lista.isEmpty
                      ? const PustyWidget()
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: lista.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return Wiersz1Widget(
                              itemIndex: index,
                              itemData: lista[index],
                            );
                          },
                        ),
                ),

                // --- DOLNY PASEK: PRZYCISK "DODAJ DO LISTY" ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.bottomGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (ctx) => const EdytorwierszaWidget(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF92F5ED),
                          foregroundColor: const Color(0xFF15766E),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          AppTranslations.tr('add_to_list', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15766E),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
