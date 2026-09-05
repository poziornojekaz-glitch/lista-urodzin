import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/share_item.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class WierszprzekazWidget extends StatelessWidget {
  const WierszprzekazWidget({
    super.key,
    required this.itemOsoba,
    required this.itemIndex,
  });

  final ListaDoUdostepnienia itemOsoba;
  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().wybranyJezyk;

    String dateFormatted = '';
    String yearFormatted = '';

    if (itemOsoba.przekazdate != null) {
      dateFormatted = DateFormat("d MMMM", lang).format(itemOsoba.przekazdate!);
      if (itemOsoba.przekazdate!.year > 1900) {
        yearFormatted = "${itemOsoba.przekazdate!.year}";
      }
    }

    return Container(
      width: double.infinity,
      height: 65,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const SizedBox(width: 8),
          Checkbox(
            value: itemOsoba.czyprzekazac,
            activeColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary, width: 2),
            onChanged: (val) {
              context.read<AppState>().toggleShareItem(itemIndex, val ?? false);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemOsoba.przekazimie.isNotEmpty ? itemOsoba.przekazimie : 'Imię',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dateFormatted,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF556068),
                      ),
                    ),
                    if (yearFormatted.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        yearFormatted,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF556068),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
