import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lista_item.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/custom_functions.dart';
import '../utils/translations.dart';
import 'edytorwiersza_widget.dart';

class Wiersz1Widget extends StatelessWidget {
  const Wiersz1Widget({
    super.key,
    required this.itemData,
    required this.itemIndex,
  });

  final ListaItem itemData;
  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lang = state.wybranyJezyk;

    // Obliczamy kolor daty
    Color dateColor = const Color(0xFF2C3E50);
    if (CustomFunctions.czyBliskoUrodziny(itemData.datazapisz)) {
      dateColor = AppTheme.redAlert;
    } else if (CustomFunctions.czyToNajblizszaData(itemData.datazapisz, state.urodzinyList)) {
      dateColor = AppTheme.blueNext;
    }

    // Formatowanie tekstu daty
    String formattedDate = '';
    String yearSuffix = '';
    if (itemData.datazapisz != null) {
      if (itemData.datazapisz!.year <= 1900) {
        formattedDate = DateFormat("d MMMM", lang).format(itemData.datazapisz!);
      } else {
        formattedDate = DateFormat("d MMM", lang).format(itemData.datazapisz!);
        yearSuffix = "${itemData.datazapisz!.year} ${AppTranslations.tr('year_label', lang).toLowerCase()}";
      }
    }

    // Obliczenie wieku
    final String wiek = CustomFunctions.obliczWiekOsoby(itemData.datazapisz, lang);

    return Container(
      width: double.infinity,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // Checkbox powiadomień dla osoby
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Checkbox(
              value: itemData.czyPowiadamiac,
              activeColor: AppTheme.primaryActive,
              side: const BorderSide(color: Color(0xFFBFC6CC), width: 2),
              onChanged: (newVal) async {
                final val = newVal ?? false;
                await context.read<AppState>().togglePowiadamiac(itemIndex, val);
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      content: Text(
                        val
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
              },
            ),
          ),

          // Informacje: Imię, Data, Wiek
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemData.tekst.isNotEmpty
                        ? itemData.tekst
                        : AppTranslations.tr('enter_name_or_event', lang),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        formattedDate.isNotEmpty ? formattedDate : 'Dodaj Datę',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: dateColor,
                        ),
                      ),
                      if (yearSuffix.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Text(
                          yearSuffix,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: dateColor,
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      if (wiek.isNotEmpty)
                        Text(
                          wiek,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF556068),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Przyciski akcji (edycja i usunięcie)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Przycisk edycji
                InkWell(
                  onTap: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        content: Text(AppTranslations.tr('edit_confirm', lang)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(AppTranslations.tr('no', lang)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(AppTranslations.tr('yes', lang)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (ctx) => EdytorwierszaWidget(
                          initialItem: itemData,
                          editIndex: itemIndex,
                        ),
                      );
                    }
                  },
                  child: const Icon(
                    Icons.border_color_outlined,
                    color: Color(0xFF677681),
                    size: 20,
                  ),
                ),

                // Przycisk usunięcia
                InkWell(
                  onTap: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        content: Text(AppTranslations.tr('delete_confirm', lang)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(AppTranslations.tr('no', lang)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(AppTranslations.tr('yes', lang)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await context.read<AppState>().removeUrodziny(itemIndex);
                    }
                  },
                  child: const Icon(
                    Icons.close_outlined,
                    color: AppTheme.deleteRed,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
