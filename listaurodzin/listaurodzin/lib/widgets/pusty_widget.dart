import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../utils/translations.dart';

class PustyWidget extends StatelessWidget {
  const PustyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().wybranyJezyk;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Text(
          AppTranslations.tr('empty_list', lang),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF677681),
          ),
        ),
      ),
    );
  }
}
