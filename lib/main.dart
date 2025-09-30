import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/ui/views/home_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo Bibliotecario UV',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        drawerTheme: DrawerThemeData(backgroundColor: Colors.white, surfaceTintColor: primaryColor),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: primaryColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      home: HomeView(onLocaleChange: setLocale),
    );
  }
}
