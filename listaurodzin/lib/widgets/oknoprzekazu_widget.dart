import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/custom_functions.dart';
import '../utils/translations.dart';
import 'wierszprzekaz_widget.dart';

class OknoprzekazuWidget extends StatelessWidget {
  const OknoprzekazuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.wybranyJezyk;
    final shareList = state.tymczasowaListaShare;
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.9,
          height: size.height * 0.85,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                // Przycisk zamknięcia
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                // Nagłówek
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppTranslations.tr('share_select_prompt', lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF248C80),
                    ),
                  ),
                ),

                // Lista osób z checkboxami
                Expanded(
                  child: shareList.isEmpty
                      ? Center(
                          child: Text(
                            AppTranslations.tr('empty_list', lang),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: shareList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            return WierszprzekazWidget(
                              itemIndex: index,
                              itemOsoba: shareList[index],
                            );
                          },
                        ),
                ),

                // Przycisk "Wyślij"
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (alertDialogContext) {
                          return AlertDialog(
                            content: Text(AppTranslations.tr('share_ask', lang)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(alertDialogContext, false),
                                child: Text(AppTranslations.tr('no', lang)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(alertDialogContext, true),
                                child: Text(AppTranslations.tr('yes', lang)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true && context.mounted) {
                        final textToSend = CustomFunctions.budujTekstDoWysylki(
                          state.tymczasowaListaShare,
                          lang,
                        );
                        await Share.share(textToSend);
                      }
                    },
                    icon: const Icon(Icons.email_outlined, color: Colors.white, size: 22),
                    label: Text(
                      AppTranslations.tr('send', lang),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
