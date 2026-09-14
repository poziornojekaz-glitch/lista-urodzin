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

    return DefaultTabController(
      length: 2,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: size.width * 0.92,
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
                  // Górny pasek: Zakładki + Zamknięcie
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          labelColor: AppTheme.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppTheme.primary,
                          indicatorWeight: 3,
                          tabs: [
                            Tab(
                              icon: const Icon(Icons.share, size: 20),
                              text: AppTranslations.tr('tab_share', lang),
                            ),
                            Tab(
                              icon: const Icon(Icons.save_outlined, size: 20),
                              text: AppTranslations.tr('tab_backup', lang),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Zawartość zakładek
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Zakładka 1: Przekazanie zaznaczonych osób
                        _buildShareTab(context, state, lang, shareList),

                        // Zakładka 2: Kopia zapasowa i Dodaj z telefonu
                        _buildBackupTab(context, state, lang),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareTab(
    BuildContext context,
    AppState state,
    String lang,
    List<dynamic> shareList,
  ) {
    return Column(
      children: [
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
                      itemOsoba: state.tymczasowaListaShare[index],
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
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
    );
  }

  Widget _buildBackupTab(
    BuildContext context,
    AppState state,
    String lang,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        children: [
          // KARTA 1: ZAPISZ KOPIĘ
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_upload_outlined, color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppTranslations.tr('backup_card_title', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppTranslations.tr('backup_card_desc', lang),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await state.exportBackupFile();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppTranslations.tr('import_error', lang))),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                    label: Text(
                      AppTranslations.tr('backup_save_btn', lang),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // KARTA 2: DODAJ LISTĘ Z TELEFONU
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F8CFF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.file_open_outlined, color: Color(0xFF3F8CFF), size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppTranslations.tr('restore_card_title', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppTranslations.tr('restore_card_desc', lang),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 14),

                  // Przycisk 1: Wybierz plik z telefonu
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final added = await state.importFromFile();
                        if (added != null && context.mounted) {
                          _showImportResult(context, lang, added);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          _showDialogMsg(context, AppTranslations.tr('import_error', lang));
                        }
                      }
                    },
                    icon: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 20),
                    label: Text(
                      AppTranslations.tr('restore_pick_btn', lang),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F8CFF),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Przycisk 2: Wklej ze schowka
                  OutlinedButton.icon(
                    onPressed: () {
                      _showPasteDialog(context, state, lang);
                    },
                    icon: const Icon(Icons.content_paste_rounded, color: Color(0xFF3F8CFF), size: 18),
                    label: Text(
                      AppTranslations.tr('restore_paste_btn', lang),
                      style: const TextStyle(color: Color(0xFF3F8CFF), fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: Color(0xFF3F8CFF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportResult(BuildContext context, String lang, int addedCount) {
    final String msg = addedCount > 0
        ? AppTranslations.tr('import_success', lang).replaceAll('{n}', addedCount.toString())
        : AppTranslations.tr('import_no_new', lang);
    _showDialogMsg(context, msg);
  }

  void _showDialogMsg(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPasteDialog(BuildContext context, AppState state, String lang) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.tr('paste_dialog_title', lang)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: AppTranslations.tr('paste_dialog_hint', lang),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTranslations.tr('cancel', lang)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () async {
              final text = textController.text.trim();
              Navigator.pop(ctx);
              if (text.isNotEmpty) {
                try {
                  final added = await state.importFromBackupJson(text);
                  if (context.mounted) {
                    _showImportResult(context, lang, added);
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showDialogMsg(context, AppTranslations.tr('import_error', lang));
                  }
                }
              }
            },
            child: Text(AppTranslations.tr('load', lang), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
