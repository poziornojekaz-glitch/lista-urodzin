import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_page.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja formatowania dat dla wszystkich języków (PL, EN, DE, RU)
  await initializeDateFormatting();

  // Inicjalizacja powiadomień AwesomeNotifications
  await NotificationService.initialize();

  // Inicjalizacja stanu aplikacji z pamięci lokalnej (SharedPreferences)
  final appState = AppState();
  await appState.initialize();

  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const ListaUrodzinApp(),
    ),
  );
}

class ListaUrodzinApp extends StatelessWidget {
  const ListaUrodzinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().wybranyJezyk;

    return MaterialApp(
      title: 'Lista Urodzin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(lang),
      supportedLocales: const [
        Locale('pl', 'PL'),
        Locale('en', 'US'),
        Locale('de', 'DE'),
        Locale('ru', 'RU'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(),
    );
  }
}
